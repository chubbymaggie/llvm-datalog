DB = test
DATA   = ./facts
IMPORT = ./import
LOGIC  = ./logic
EXAMPLES = ./examples

OPERAND_PRED_LIST = ./operand-pred-list.txt

TESTS = $(wildcard $(EXAMPLES)/*.c)
TESTBUILD = $(EXAMPLES)/build
TESTOUT = $(TESTS:$(EXAMPLES)/%.c=$(TESTBUILD)/%.s)

SCHEMA = $(LOGIC)/schema.logic
IMPORT_BLOCK = $(LOGIC)/parse.logic

# Various scripts
GEN = ./generate-import.sh
LOGIC_GEN = ./import-logic-gen
EXTRACTOR = ./extract-operand-predicates.sh

# Entities
ENTITIES = $(DATA)/entities
ENTITY_FILES = $(wildcard $(ENTITIES)/*.dlm)
ENTITY_IMPORTS = $(ENTITY_FILES:$(ENTITIES)/%.dlm=$(IMPORT)/%.import)
ENTITY_SCRIPT = $(IMPORT)/entities.import

# Predicates
PREDICATES=$(DATA)/predicates
PREDICATE_FILES = $(wildcard $(PREDICATES)/*.dlm)
PREDICATE_IMPORTS = $(PREDICATE_FILES:$(PREDICATES)/%.dlm=$(IMPORT)/%.import)
PREDICATE_SCRIPT = $(IMPORT)/predicates.import

all: import-predicates

create:
	bloxbatch -db $(DB) -create -overwrite
	bloxbatch -db $(DB) -addBlock -file $(SCHEMA)

delete:
	rm -rf $(DB)/

import-entities: $(ENTITY_SCRIPT)
	bloxbatch -db $(DB) -import $<

import-predicates: $(PREDICATE_SCRIPT)
	bloxbatch -db $(DB) -import $<
	bloxbatch -db $(DB) -execute -file $(IMPORT_BLOCK)

# Generate import logic
$(IMPORT_BLOCK): %.logic: %.logic.template
	cat $(OPERAND_PRED_LIST) | $(LOGIC_GEN) "$(DATA)" | cat $< - > $@

$(OPERAND_PRED_LIST):
	$(EXTRACTOR) $(SCHEMA) > $@

# Generate .import files

$(ENTITY_IMPORTS): $(IMPORT)/%.import: $(ENTITIES)/%.dlm
	$(GEN) $< > $@

$(PREDICATE_IMPORTS): $(IMPORT)/%.import: $(PREDICATES)/%.dlm
	$(GEN) $< > $@

# Collect all generated .import files into one

$(ENTITY_SCRIPT): $(ENTITY_IMPORTS)
	@echo "option,delimiter,\"	\"" > $@
	@echo "option,hasColumnNames,false" >> $@
	@cat $^ >> $@

$(PREDICATE_SCRIPT): $(PREDICATE_IMPORTS)
	@echo "option,delimiter,\"	\"" > $@
	@echo "option,hasColumnNames,false" >> $@
	@cat $^ >> $@

# Unit tests in C

$(TESTOUT): $(TESTBUILD)/%.s : $(EXAMPLES)/%.c
	@mkdir -p $(@D)
	clang -S -emit-llvm $< -o $@

tests: $(TESTOUT)

# Additional dependencies
import-predicates: import-entities $(IMPORT_BLOCK)
import-entities: create

$(ENTITY_IMPORTS): $(GEN)
$(PREDICATE_IMPORTS): $(GEN)
$(IMPORT_BLOCK): $(OPERAND_PRED_LIST) $(LOGIC_GEN)
$(OPERAND_PRED_LIST): $(EXTRACTOR) $(SCHEMA)

.PHONY: all create delete import-entities import-predicates tests
