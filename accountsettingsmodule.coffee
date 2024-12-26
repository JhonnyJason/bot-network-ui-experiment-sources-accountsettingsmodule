############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountsettingsmodule")
#endregion

############################################################
#region modulesFromEnvironment
import * as utl from "./utilsmodule.js"
import * as qrDisplay from "./qrdisplaymodule.js"
import * as triggers from "./navtriggers.js"

############################################################
import * as keygeneration from "./keygeneration.js"
import * as keyimport from "./keyimport.js"
import * as keyexport from "./keyexport.js"

#endregion

############################################################
idDisplay = document.getElementById("id-display")
idContent = idDisplay.getElementsByClassName("display-frame-content")[0]

############################################################
export initialize = ->
    log "initialize"
    idDisplay.addEventListener("click", idDisplayClicked)
    idQrButton.addEventListener("click", idQrButtonClicked)
    

    generateKeyButton.addEventListener("click", generateKeyButtonClicked)
    importKeyButton.addEventListener("click", importKeyButtonClicked)
    exportKeyButton.addEventListener("click", exportKeyButtonClicked)
    deleteKeyButton.addEventListener("click", deleteKeyButtonClicked)

    keygeneration.initialize()
    keyimport.initialize()    
    keyexport.initialize()
    return

############################################################
#region eventListeners
idDisplayClicked = ->
    log "idDisplayClicked"
    utl.copyToClipboard(idContent.textContent)
    return

idQrButtonClicked = ->
    log "idDisplayClicked"
    qrDisplay.displayCode(idContent.textContent)
    return

############################################################
generateKeyButtonClicked = ->
    log "generateKeyButtonClicked"
    triggers.keyGeneration()
    return

importKeyButtonClicked = ->
    log "importKeyButtonClicked"
    triggers.keyImport()
    return

exportKeyButtonClicked = ->
    log "exportKeyButtonClicked"
    triggers.keyExport()
    return

deleteKeyButtonClicked = ->
    log "deleteKeyButtonClicked"
    triggers.deleteKey()
    return

#endregion

############################################################
export displayKeyId = (keyId) ->
    log "displayKeyId"
    idContent.textContent = keyId
    if keyId then document.body.classList.remove("no-key")
    else document.body.classList.add("no-key")
    return

############################################################
#region UI Functions
export setToKeyGeneration = ->
    log "setToKeyGeneration"
    accountsettings.className = "generate-key"
    return

export setToKeyImport = ->
    log "setToKeyImport"
    accountsettings.className = "import-key"
    return

export setToKeyExport = ->
    log "setToKeyExport"
    accountsettings.className = "export-key"
    return

export setOff = ->
    log "setOff"
    accountsettings.className = ""
    return
    
#endregion


#92e102b2b2ef0d5b498fae3d7a9bbc94fc6ddc9544159b3803a6f4d239d76d62