mod = angular.module "starter.controllers"

mod.factory "mmFileSystem", ->
  factory =
  
    #returns a directory handle on local fileSystem
    getFsDirectory: (directoryName, getDirectorySuccess) ->
      
      fileSystemSuccess = (fs) ->
        console.log "file system request success" 
        fs.root.getDirectory directoryName, {create: true}, getDirectorySuccess
      
      fileSystemFail = ->
        console.log "file system request failed"
    
      window.requestFileSystem LocalFileSystem.TEMPORARY, 0, fileSystemSuccess, fileSystemFail
    
  return factory