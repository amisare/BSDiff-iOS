platform :ios, '8.0'

use_frameworks!

workspace 'BSDiff'

def all_pods
    pod 'BSDiff', :path => '.'
    pod "FileMD5Hash"
end

target :BSDiffExample do
    project './Example/BSDiffExample'
    all_pods
end
