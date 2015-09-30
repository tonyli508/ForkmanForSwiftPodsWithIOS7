#
#  Forkman.rb
#  SwiftLibrariesPods
#
#  Created by Li Jiantang on 27/08/2015.
#  Copyright (c) 2015 Carma. All rights reserved.
#

require 'xcodeproj'

# Update third party dependencies
module ThirdPartyDependencies
    
    # config updating settings
    module Configuration
       
       # the project name we copy libraries to
       DESTINATION_PROJECT_NAME = "../../ForkmanForSwiftPodsWithIOS7.xcodeproj"
       
       # the folder name we copy libraries to
       DESTINATION_FOLDER_NAME = "SwiftPodsLibraries"
       
       # the project name we copy libraries from
       SOURCE_PROJECT_NAME = "./Pods/Pods.xcodeproj"
       
       # the folder name we copy libraries from
       SOURCE_FOLDER_NAME = "Pods"
       
       # ignoring groups
       IGNORING_GROUPS = ["Support Files", "Local Podspecs", "Target Support Files"]
       
       # ignoring files
       IGNORING_FILES = ["LICENSE", "README.md", "Info.plist"]
       
       # all the target we want to add the files to, for build phase
       DESTINATION_TARGET_NAMES = ["ForkmanForSwiftPodsWithIOS7"]
       
    end
    
    
    class LibrariesForkman
        
        #the group name will copy to for the destination project
        attr_accessor :destination_group_name
        
        #the group name will copy from for the source project
        attr_accessor :source_group_name
        
        #source project that all swift libraries copy from, SwiftLibrariesPods
        attr_accessor :source_project
        
        #destination project that all swift libraries copy to, ForkmanForSwiftPodsWithIOS7
        attr_accessor :destination_project
        
        def initialize()
            
            # init source
            @source_project = Xcodeproj::Project.open(Configuration::SOURCE_PROJECT_NAME)
            @source_group_name = Configuration::SOURCE_FOLDER_NAME
            
            # init destination
            @destination_project = Xcodeproj::Project.open(Configuration::DESTINATION_PROJECT_NAME)
            @destination_group_name = Configuration::DESTINATION_FOLDER_NAME
            
            @destination_targets = []
            
            puts "\n-----------Show all destination targets------------\n"
            
            Array(@destination_project.native_targets).each do |target|
                if Configuration::DESTINATION_TARGET_NAMES.include?(target.name)
                    puts "target: " + target.name
                    @destination_targets << target
                end
            end
        end
        
        # clear up old dependencies and copy new ones
        def forklift(testing = false)
            
            source = self.getGroup(@source_project, @source_group_name)
            destination = self.getGroup(@destination_project, @destination_group_name)
            
            puts "\n--------------Fork truck started-------------------\n"
            puts "Clear all the destination references:"
            printGroups(destination.groups)
            
            Array(destination.recursive_children).each do |child|
                if child.class == Xcodeproj::Project::Object::PBXFileReference
                    Array(@destination_targets).each do |target|
                        puts "deleting file: " + child.path
                        target.source_build_phase.remove_file_reference(child)
                    end
                end
            end
            
            destination.clear()
            puts "\n-----------------Clear done.-----------------------\n"
            
            puts "Copy all the source group references:"
            Array(source.groups).each do |subgroup|
                recursiveCopy(subgroup, destination)
            end
            
            # for testing we just print the logs
            if !testing
                @destination_project.save()
            end
            
            puts "\n-----------------All fork done.--------------------\n"
            
        end
        
        # recursively copy groups and files
        def recursiveCopy(fromGroup, toGroup)
            
            if shouldIgnoreGroup(fromGroup)
               return
            end
            
            puts "copying from group: " + self.getGroupName(fromGroup) + " to group: " + self.getGroupName(toGroup)
            
            newGroup = toGroup.new_group(self.getGroupName(fromGroup), fromGroup.real_path)
            
            addedFiles = []
            
            Array(fromGroup.files).each do |child|
                unless shouldIgnoreFile(child) then
                    puts "copying file: " + child.path
                    addedFiles << newGroup.new_file(child.real_path)
                end
            end
            
            addFilesToTargets(addedFiles)

            Array(fromGroup.groups).each do |child|
                recursiveCopy(child, newGroup)
            end
            
        end
        
        # add files references to build targets
        def addFilesToTargets(files)
            
            Array(@destination_targets).each do |target|
                target.add_file_references(files)
            end
            
        end
        
        # file filters
        def shouldIgnoreFile(file)
            
            return Configuration::IGNORING_FILES.include?(file.path)
            
        end
        
        # group filters
        def shouldIgnoreGroup(group)
            
            return Configuration::IGNORING_GROUPS.include?(self.getGroupName(group))
            
        end
        
        # get group name from group reference
        def getGroupName(group)
            
            _name = nil
            
            if group.name
                _name = group.name
                else
                _name = group.path
            end
            
            return _name
            
        end
        
        # get the group references for a give project and group name
        def getGroup(project = @source_project, groupName = @source_group_name)
            
            wanted = nil
            
            Array(project.groups).each do |group|
                
                if self.getGroupName(group) == groupName
                    wanted = group
                end
            end
            
            return wanted
        end
        
        # debug print all groups for project
        def printGroups(groups = @source_project.groups)
            
            Array(groups).each do |group|
                puts self.getGroupName(group)
            end
            
        end
    end
end

forkman = ThirdPartyDependencies::LibrariesForkman.new
forkman.forklift()