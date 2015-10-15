mod = angular.module "starter.controllers"

mod.factory "mmDownloads", ($q, mmFileSystem) ->
  factory =
  
    downloadFile: (fileName, url) ->
      defer = $q.defer()
          
      getFileSuccess = (fileEntry) ->
        console.log "get file success"
        fileEntryToURL = fileEntry.toURL()
        fileEntry.remove()
        ft = new FileTransfer()
        
        downloadSuccess = (entry) ->
          console.log "download success"
          defer.resolve entry.toInternalURL()
          
        downloadFail = (error) ->
          console.log "download failed", error.source
          defer.reject error.source
        
        currentProgress = 0
        ft.onprogress = (progressEvent) ->
          if (progressEvent.lengthComputable)
            newProgress = parseInt(progressEvent.loaded / progressEvent.total * 100)
            if newProgress > currentProgress
              currentProgress = newProgress
              defer.notify currentProgress
              
          else
            console.log "progress length not computable!"
  
        ft.download encodeURI(url), fileEntryToURL, downloadSuccess, downloadFail, false, null
        
      getFileFail = (error) ->
        console.log "get file failed"
        defer.reject error
      
      getDirectorySuccess = (dirEntry) ->
        dirEntry.getFile fileName, {create: true, exclusive: false}, getFileSuccess, getFileFail
      
      mmFileSystem.getFsDirectory "mobileMeditationData", getDirectorySuccess
      
      return defer.promise
  
  return factory