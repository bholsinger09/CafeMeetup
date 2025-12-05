require 'xcodeproj'

project_path = 'CafeMeetup.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Files to add with their paths
files_to_add = {
  'CafeMeetup/Models/CoffeeBadge.swift' => 'Models',
  'CafeMeetup/Models/StudySession.swift' => 'Models',
  'CafeMeetup/Views/StudySessionsView.swift' => 'Views',
  'CafeMeetup/Views/BadgesRewardsView.swift' => 'Views'
}

files_to_add.each do |file_path, group_name|
  # Find or create the group
  group = project.main_group.find_subpath(File.join('CafeMeetup', group_name), true)
  
  # Add file reference
  file_ref = group.new_reference(file_path)
  
  # Add to build phase
  target.source_build_phase.add_file_reference(file_ref)
  
  puts "Added #{file_path}"
end

project.save
puts "Project saved successfully!"
