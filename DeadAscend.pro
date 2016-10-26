TEMPLATE = subdirs
SUBDIRS += \
	App

# Use ordered build, from first subdir (project_a) to the last (project_b):
CONFIG += ordered
