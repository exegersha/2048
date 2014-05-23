#########################################################################
#
# Makefile Usage:
# > make
# > make install
# > make remove
# > make pkg
# > make clean
#
# Use the "NO_AUTH=1" option to deploy to roku boxes with firmware < 5.2
#	that do not have the developer username/password
# Important Notes: You must do the following to use this Makefile:
#
# 1) Make sure that you have the make and curl commands line executables
#	 in your path
# 2) Define ROKU_DEV_TARGET either below, or in an environment variable
#	 set to the IP address of your Roku box.
#	 (e.g. export ROKU_DEV_TARGET=192.168.1.1)
#
##########################################################################


# ----------------- YOU CAN EDIT THE VARIABLES BELOW -----------------

# Application version for packaging
VERSION = 0
# Name your app! This will be used for the name of the zip file created
# 	and for packaging the app before publishing to the channel store.
APPNAME = "NowTv"

# The username/password you set on your Roku when enabling developer mode
# You are advised to use rokudev / abcd321 to help working together!
ROKU_DEV_USERNAME = rokudev
ROKU_DEV_PASSWORD = abcd321

# The ip address of the roku box you want to deploy a build to.
# If you use only one box, you can set this in an environment variable
#	but this value will override it
#ROKU_DEV_TARGET = X.X.X.X

# If your roku box has authentication active (Roku firmwares 5.2 and above),
#	set this to 0
# If you use only one box, you can set this in an environment variable
#	but this value will override it
NO_AUTH=1

# Specify here if you want to use the source version of the framework
#	which will be updated at each build, or leave the current
#	framework directory intact, so you can change it and rebuild the
#	app without losing these changes.
#
# Values possible are:
#	source (default) => reset framework local repository
#			  and pull latest revision at each build
#
#	dev => leave current framework repository intact
#
#	v_1.0.2 => or any other tag on the framweork repository
#
# In all cases, if no framework directory has been found,
#	a fresh copy will be pulled from the git repo first.
# If a tag is provided, this particular one will be checked-out

FRAMEWORK_TO_USE = dev



# --------------------------------------------------------------------------------
# ---------------- STOP EDITING HERE. DON'T CHANGE ANYTHING BELOW!! --------------
# --------------------------------------------------------------------------------

GIT_FRAMEWORK_REPO = git@gitlab.nowtv.bskyb.com:roku-framework.git
# DON'T CHANGE THAT NAME!! IT MUST BE THE SAME AS THE REPO NAME ABOVE
FRAMEWORK_DIR = roku-framework
FRAMEWORK_TARGET_DIR := $(shell ls -d ../$(FRAMEWORK_DIR) | tail -n 1)

BUILDDIR = build
OUT_DIR = out
PKG_DIR = pkg

#APP_INCLUDES = fonts images source manifest
APP_INCLUDES = images source manifest
TEST_LIBRARIES = tests/Main.brs tests/brstest.brs tests/mocks tests/utilities.brs
TEST_SUITES = tests/testsSuites
ZIP_EXCLUDES = --exclude=*.DS_Store* --exclude=*.git*

$(APPNAME): build zip cleanup
install: $(APPNAME) deploy
test: build addtests zip cleanup deploy

build: cloneframework

	@echo ""
	@echo ""
	@echo ""
	@echo "3 - Now I'm removing the previously built"
	@echo "    application archive if it exists and"
	@echo "    setting up all the required directories"
	@echo "    for the final build"
	@echo "--------------------------------------------------------"
	@echo ""

	@if [ -e "$(OUT_DIR)/$(APPNAME).zip" ]; \
	then \
		echo "There is an old build here! Deleting it."; \
		rm  $(OUT_DIR)/$(APPNAME).zip; \
		echo "... done." ; \
	fi

	@echo ""

	@if [ ! -d $(OUT_DIR) ]; \
	then \
		echo "Creating missing output directory."; \
		mkdir -p $(OUT_DIR); \
		echo "... done." ; \
	fi

	@if [ ! -w $(OUT_DIR) ]; \
	then \
		echo "Making the output directory writable."; \
		chmod 755 $(OUT_DIR); \
		echo "... done." ; \
	fi

	@if [ -d $(BUILDDIR) ]; \
	then \
		echo "There is an old build directory here! Deleting it."; \
		rm -rf $(BUILDDIR); \
		echo "... done." ; \
	fi

	@if [ ! -d $(BUILDDIR) ]; \
	then \
		echo "Creating a new build directory."; \
		mkdir -p $(BUILDDIR); \
		echo "... done." ; \
	fi

	@if [ ! -w $(BUILDDIR) ]; \
	then \
		echo "Making the build directory writable."; \
		chmod 755 $(BUILDDIR); \
		echo "... done." ; \
	fi
	@echo "... all done!"

	@echo ""
	@echo ""
	@echo ""
	@echo "4 - Before I can fill up this archive, I need"
	@echo "    to have all the source code neatly in one place."
	@echo "    So I'm copying all of that into the build"
	@echo "    dir at $(BUILDDIR)";
	@echo "--------------------------------------------------------"
	@echo ""

	cp -r ../$(FRAMEWORK_DIR)/source $(BUILDDIR)/
	cp -r $(APP_INCLUDES) $(BUILDDIR)/
	@echo "... done."


zip:

	@echo ""
	@echo ""
	@echo ""
	@echo "5 - This is now done, as we're at the final step:"
	@echo "    Zip it all up in $(OUT_DIR)/$(APPNAME).zip!"
	@echo "--------------------------------------------------------"
	@echo ""

	pushd ./$(BUILDDIR)/; \
	zip -q -0 -r "../$(OUT_DIR)/$(APPNAME).zip" . -i \*.png $(ZIP_EXCLUDES); \
	zip -q -9 -r "../$(OUT_DIR)/$(APPNAME).zip" . -x \*.png $(ZIP_EXCLUDES); \
	popd
	@echo "... done."


cleanup:

	@echo ""
	@echo ""
	@echo ""
	@echo "6 - The application archive has been created! Now I'm"
	@echo "    doing a bit of cleanup by build folder '$(BUILDDIR)'"
	@echo "--------------------------------------------------------"
	@echo ""

	rm -rf $(BUILDDIR)
	@echo "... done."

cloneframework:
	@echo "---------------------------------------------------------"
	@echo "|   Hold on tight! I'm building your Roku application!  |"
	@echo "---------------------------------------------------------"
	@echo ""

	@if [ -z "$(FRAMEWORK_TO_USE)" ]; \
	then \
		echo "/!\ It seems you didn't set the FRAMEWORK_TO_USE variable. Please read the instruction and make the required changes"; \
		exit 1; \
	fi

	@echo "1 - First, I'm getting the required version"
	@echo "    of the NowTV Roku Framework"
	@echo "--------------------------------------------------------"
	@echo ""

ifeq (,$(FRAMEWORK_TARGET_DIR))
	@echo "You don't have any version of the framework right now. Cloning a fresh version. Additionally, if you specified a tag, we're checking that one out."

	ssh-agent bash -c 'cd ../; pwd; ssh-add ~/.ssh/id_rsa.pub; git clone $(GIT_FRAMEWORK_REPO); cd $(FRAMEWORK_DIR); git checkout master'

ifneq ($(FRAMEWORK_TO_USE),source)
ifneq ($(FRAMEWORK_TO_USE),dev)
	ssh-agent bash -c 'cd ../; pwd; ssh-add ~/.ssh/id_rsa.pub; cd $(FRAMEWORK_DIR); git fetch origin; git checkout $(FRAMEWORK_TO_USE)'
endif
endif

	@echo "... done."
else ifeq ($(FRAMEWORK_TO_USE),source)
	@echo "You already have a version of the framework repo."
	@echo "I just need to reset it and pull the correct version."
	@echo ""

	ssh-agent bash -c 'cd ../$(FRAMEWORK_DIR); git reset --hard HEAD; git checkout master; git pull origin master'

	@echo "... done."
else ifeq ($(FRAMEWORK_TO_USE),dev)
	@echo "You specifically said that you use a dev version of the framework"
	@echo "I'll leave your current framework just as it is then"
	@echo ""
else
	ssh-agent bash -c 'cd ../$(FRAMEWORK_DIR); git fetch origin; git checkout $(FRAMEWORK_TO_USE)'
endif

	@echo ""
	@echo ""
	@echo ""
	@echo "2 - All done with the framework!"
	@echo "    I'm now ready to package everything."
	@echo "--------------------------------------------------------"
	@echo ""

	cd ..

deploy:

	@echo ""
	@echo ""
	@echo ""
	@echo "7 - To install your application, I first need to"
	@echo "    check that you have given me a target to"
	@echo "    deploy to."
	@echo "--------------------------------------------------------"
	@echo ""

	@if [ -z "$(ROKU_DEV_TARGET)" ]; \
	then \
		echo "/!\ It seems you didn't set the ROKU_DEV_TARGET environment variable to the hostname or IP of your device, or set it in the makefile in the editable section."; \
		exit 1; \
	fi
	@echo "... done."

	@echo ""
	@echo ""
	@echo ""
	@echo "8 - Cool, I know where to install your application!"
	@echo "    Now sending it to host $(ROKU_DEV_TARGET)"
	@echo "--------------------------------------------------------"
	@echo ""

	@if [ $(NO_AUTH) = 1 ]; \
	then \
		curl -s -S -F "mysubmit=Install" -F "archive=@$(OUT_DIR)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["; \
	else \
		curl --user $(ROKU_DEV_USERNAME):$(ROKU_DEV_PASSWORD) --digest -s -S -F "mysubmit=Install" -F "archive=@$(OUT_DIR)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["; \
	fi
	@echo "... done."

	@echo ""
	@echo ""
	@echo ""
	@echo "9 - Hey it's all done! Your app '$(APPNAME)' should now"
	@echo "    have oppened on your Roku! Enjoy!"
	@echo "--------------------------------------------------------"
	@echo ""

pkg: install

	@echo "Packaging $(APPNAME) on host $(ROKU_DEV_TARGET)"

	@if [ ! -d $(PKG_DIR) ]; \
	then \
		mkdir -p $(PKG_DIR); \
	fi

	@if [ ! -w $(PKG_DIR) ]; \
	then \
		chmod 755 $(PKG_DIR); \
	fi

	@if [ $(NO_AUTH) = 1 ]; \
	then \
		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl  -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep 'href="pkgs' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's/pkgs\/\///' | xargs -i curl -s -S -o $(PKG_DIR)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}; \
	else \
		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl --user $(ROKU_DEV_USERNAME):$(ROKU_DEV_PASSWORD) --digest -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep 'href="pkgs' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's/pkgs\/\///' | xargs -i curl -s -S -o $(PKG_DIR)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}; \
	fi

	@echo "Done packaging $(APPNAME) on host $(ROKU_DEV_TARGET)"

# Commenting this one for now.
# If we really want it, we need to build in some error
# 	control when there are no packages available so
# 	curl doesn't explode

# get-pkg:
# 	@echo "RETRIEVING $(APPNAME) on host $(ROKU_DEV_TARGET)"

# 	@if [ ! -d $(PKG_DIR) ]; \
# 	then \
# 		mkdir -p $(PKG_DIR); \
# 	fi

# 	@if [ ! -w $(PKG_DIR) ]; \
# 	then \
# 		chmod 755 $(PKG_DIR); \
# 	fi

# 	@if [ $(NO_AUTH) = 1 ]; \
# 	then \
# 		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep 'href="pkgs' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's/pkgs\/\///' | xargs -i curl -s -S -o $(PKG_DIR)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}; \
# 	else \
# 		read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl --user $(ROKU_DEV_USERNAME):$(ROKU_DEV_PASSWORD) --digest -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep 'href="pkgs' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's/pkgs\/\///' | xargs -i curl -s -S -o $(PKG_DIR)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}; \
# 	fi

# 	@echo "Done getting $(APPNAME) from host $(ROKU_DEV_TARGET)"

addtests:

	@echo ""
	@echo ""
	@echo ""
	@echo "* - Before I can fill up this archive, I need"
	@echo "    to have all the source code neatly in one place."
	@echo "    So I'm copying all of that into the build"
	@echo "    dir at $(BUILDDIR)";
	@echo "--------------------------------------------------------"

ifeq (,$(suite))
	$(eval testIncludes="$(TEST_SUITES)")
else
	$(eval testIncludes="$(TEST_SUITES)/$(suite)")
endif

	@echo ""

	cp -r $(TEST_LIBRARIES) $(BUILDDIR)/source
	cp -r $(testIncludes) $(BUILDDIR)/source
	@echo "... done."

remove:

	@if [[ $(NO_AUTH) = 1 ]]; \
	then \
		echo "NOAUTH IS TRUE (remove)"; \
	else \
		echo "NOAUTH IS FALSE (remove)"; \
	fi

	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"

	@if [ $(NO_AUTH) = 1 ]; \
	then \
		curl -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["; \
	else \
		curl --user $(ROKU_DEV_USERNAME):$(ROKU_DEV_PASSWORD) --digest -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["; \
	fi

clean:
	@echo "Cleaning output directory..."
	@if [ -d $(OUT_DIR) ]; \
	then \
		rm -rf $(OUT_DIR); \
	fi

	@echo "Cleaning build directory..."
	@if [ -d $(BUILDDIR) ]; \
	then \
		rm -rf $(BUILDDIR); \
	fi

	@echo "Cleaning packages directory..."
	@if [ -d $(PKG_DIR) ]; \
	then \
		rm -rf $(PKG_DIR); \
	fi

	@echo "All done!"
