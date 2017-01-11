COURSE_NAME := $(subst course_,,$(notdir $(shell pwd)))
MATERIALS_PREFIX := materials
MATERIALS := $(shell find . -type d -name 'materials_*')
INIT_FILE := .init

GIT_REPO := git@github.com:gustybear/project-template.git

GIT_BRANCH_SYLLABUS := course_syllabus
SYLLABUS_DIR := $(MATERIALS_PREFIX)_syllabus

GIT_BRANCH_COURSE_WEEKLY := course_weekly
NUM_OF_WEEKS := $(words $(shell find . -type d -name '*week*'))
NUM_OF_NEXT_WEEKS := $(shell echo $$(( $(NUM_OF_WEEKS) + 1 )))
NEXT_WEEKS_DIR = $(MATERIALS_PREFIX)_week_$(shell printf "%02d" $(NUM_OF_NEXT_WEEKS))

.PHONY : none
none: ;

.PHONY : init
init:
ifeq ($(shell cat $(INIT_FILE)),no)
	find . -name '*.bib' -exec bash -c 'mv {} `dirname {}`/_$(COURSE_NAME)`basename {}`' \;
	find . -name '*.jemdoc' -exec bash -c 'mv {} `dirname {}`/$(COURSE_NAME)`basename {}`' \;
	find . -name '*.jemseg' -exec bash -c 'mv {} `dirname {}`/$(COURSE_NAME)`basename {}`' \;

	find . -name '*.jemdoc' -exec \
		sed -i '' 's/\([^/]*\.jeminc\)/_$(COURSE_NAME)\1/g' {} +
	find . -name '*.jemdoc' -exec \
		sed -i '' 's/\([^/]*\.bib\)/_$(COURSE_NAME)\1/g' {} +

	rm -rf .git
	git init
	$(shell echo yes > $(INIT_FILE))
endif

.PHONY : add_syllabus
add_syllabus: 
	git clone -b $(GIT_BRANCH_SYLLABUS) $(GIT_REPO) $(SYLLABUS_DIR)
	$(MAKE) -C $(SYLLABUS_DIR) init

.PHONY : add_a_week
add_a_week:
	git clone -b $(GIT_BRANCH_COURSE_WEEKLY) $(GIT_REPO) $(NEXT_WEEKS_DIR)
	$(MAKE) -C $(NEXT_WEEKS_DIR) init

.PHONY : publish
publish:
ifneq ($(MATERIALS),)
	$(MAKE) -C $(MATERIALS) publish
endif

print-%:
	@echo '$*=$($*)'