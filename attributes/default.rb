#Update System and Upgrade
default["hostupgrade"]["update_system"] = true
default["hostupgrade"]["upgrade_system"] = true

#Declare only run on first chef-client run
default["hostupgrade"]["first_time_only"] = true

#Skip the line and update package metadata during compile phase
default["hostupgrade"]["compile_time"] = false
