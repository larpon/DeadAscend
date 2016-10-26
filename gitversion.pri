# If there is no version tag in git this one will be used
isEmpty(VERSION){
  message("No version variable sat - setting to 1.0.0")
  VERSION = 1.0.0
}

# Need to discard STDERR so get path to NULL device
win32 {
    NULL_DEVICE = NUL # Windows doesn't have /dev/null but has NUL
} else {
    NULL_DEVICE = /dev/null
}

# Need to call git with manually specified paths to repository
BASE_GIT_COMMAND = git --git-dir $$PWD/.git --work-tree $$PWD

# Trying to get version from git tag / revision
GIT_INITAL_VERSION = $$system($$BASE_GIT_COMMAND describe --always --tags 2> $$NULL_DEVICE)
GIT_VERSION = $$GIT_INITAL_VERSION

# Check if we only have hash without version number
!contains(GIT_VERSION, v?\d+\.\d+\.\d+.* ) {
    # If there is nothing we simply use version defined manually
    isEmpty(GIT_VERSION) {
        GIT_VERSION = $$VERSION
    } else { # otherwise construct proper git describe string
        GIT_COMMIT_COUNT = $$system($$BASE_GIT_COMMAND rev-list HEAD --count 2> $$NULL_DEVICE)
        isEmpty(GIT_COMMIT_COUNT) {
            GIT_COMMIT_COUNT = 0
        }
        GIT_VERSION = $$VERSION-$$GIT_COMMIT_COUNT-g$$GIT_VERSION
    }
}

# Turns describe output like 0.1.5-42-g652c397 into "0.1.5.42.652c397"
GIT_VERSION ~= s/-/"."
GIT_VERSION ~= s/g/""

# Strip "v" prefix if any
GIT_VERSION ~= s/^v/""

# Now we are ready to pass parsed version to Qt
# VERSION = $$GIT_VERSION
# win32 { # On windows version can only be numerical so remove commit hash
#    VERSION ~= s/\.\d+\.[a-f0-9]{6,}//
#}

# Adding C preprocessor #DEFINE so we can use it in C++ code
# also here we want full version on every system so using GIT_VERSION
DEFINES += VERSION=\\\"$$VERSION\\\"
DEFINES += GIT_VERSION=\\\"$$GIT_VERSION\\\"

# By default Qt only uses major and minor version for Info.plist on Mac.
# This will rewrite Info.plist with full version
#macx {
#    INFO_PLIST_PATH = $$shell_quote($${OUT_PWD}/$${TARGET}.app/Contents/Info.plist)
#    QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Set :CFBundleShortVersionString $${VERSION}\" $${INFO_PLIST_PATH}
#}

message(GIT_INITAL_VERSION = $$GIT_INITAL_VERSION"," GIT_VERSION $$GIT_VERSION"," VERSION $$VERSION)
