############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("keyimport")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as utl from "./utilsmodule.js"

############################################################
#region DOM cache
useButton = document.getElementById("keyimport-use-button")
cancelButton = document.getElementById("keyimport-cancel-button")

keyIdDisplay = document.getElementById("keyimport-key-id-display")
protectedIndicator = document.getElementById("keyimport-protected-indicator")
#endregion

############################################################
currentKeyObj = null

############################################################
export initialize = ->
    log "initialize"
    useButton.addEventListener("click", useButtonClicked)
    cancelButton.addEventListener("click", cancelButtonClicked)
    return

############################################################
generateNewRawKey = ->
    log "generateNewRawKey"
    currentKeyObj = await secUtl.createKeyPairHex()
    keyIdDisplay.textContent = utl.add0x(currentKeyObj.publicKeyHex)
    protectedIndicator.className = ""
    return

############################################################
useButtonClicked = ->
    log "useButtonClicked"
    return

cancelButtonClicked = ->
    log "cancelButtonClicked"
    accountsettings.classList.remove("import-key")
    return





############################################################
qrScanImportClicked = ->
    log "qrScanImportClicked"
    try
        key = await qrReader.read()
        importKeyInput.value = key
        importKeyInputChanged()
    catch err then log err
    return

floatingImportClicked = ->
    log "floatingImportClicked"
    ##TODO implement
    return

signatureImportClicked = ->
    log "signatureImportClicked"
    ##TODO implement
    return

