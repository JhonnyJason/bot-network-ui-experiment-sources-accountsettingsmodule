############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("keygeneration")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"

############################################################
import * as utl from "./utilsmodule.js"
import * as account from "./accountmodule.js"
import * as triggers from "./navtriggers.js"

############################################################
#region DOM cache
regenerationButton = document.getElementById("keygeneration-regeneration-button")
useButton = document.getElementById("keygeneration-use-button")
cancelButton = document.getElementById("keygeneration-cancel-button")

keyIdDisplay = document.getElementById("keygeneration-key-id-display")
protectedIndicator = document.getElementById("keygeneration-protected-indicator")

goRawButton = document.getElementById("keygeneration-keep-unprotected")
phraseProtectButton = document.getElementById("keygeneration-phrase-protect")
qrProtectButton = document.getElementById("keygeneration-qr-protect")

conclusionRow = document.getElementById("keygeneration-conclusion-row 
")
#endregion

############################################################
keygenHandle = null

############################################################
export initialize = ->
    log "initialize"

    regenerationButton.addEventListener("click", regenerationButtonClicked)

    useButton.addEventListener("click", useButtonClicked)
    cancelButton.addEventListener("click", cancelButtonClicked)

    goRawButton.addEventListener("click", goRawClicked)
    phraseProtectButton.addEventListener("click", phraseProtectClicked)
    qrProtectButton.addEventListener("click", qrProtectClicked)
    
    generateNewRawKey()
    return

############################################################
generateNewRawKey = ->
    log "generateNewRawKey"
    keygenHandle = await secUtl.createKeyPairHex()
    keyIdDisplay.textContent = utl.add0x(keygenHandle.publicKeyHex)
    protectedIndicator.className = ""

    resetProtectionButtons()
    return

resetProtectionButtons = ->
    log "resetProtection"
    goRawButton.classList.remove("active")
    phraseProtectButton.classList.remove("active")
    qrProtectButton.classList.remove("active")

    conclusionRow.classList.remove("acceptable")
    return  

############################################################
useButtonClicked = ->
    log "useButtonClicked"
    account.useNewKey(keygenHandle)
    generateNewRawKey()
    triggers.back()    
    return

cancelButtonClicked = ->
    log "cancelButtonClicked"
    triggers.back()
    return

regenerationButtonClicked = ->
    log "regenerationButtonClicked"
    generateNewRawKey()
    return

goRawClicked = ->
    log "goRawClicked"
    keygenHandle.protection = "none"
    keygenHandle.keySaltHex = ""
    keygenHandle.keyTraceHex = ""

    resetProtectionButtons()
    conclusionRow.classList.add("acceptable")
    goRawButton.classList.add("active")
    protectedIndicator.className = ""
    return

phraseProtectClicked = ->
    log "phraseProtectClicked"
    resetProtectionButtons()
    triggers.phraseProtect()
    return

qrProtectClicked = ->
    log "qrProtectClicked"
    resetProtectionButtons()
    triggers.qrProtect()
    return


############################################################
createKeyProtection = (secretData) ->
    log "createKeyProtection"

    keySaltHex = await secUtl.createSymKey() # returns random 48 bytes in hex
    seed = keySaltHex + secretData
    splitterKeyHex = await utl.seedToKey(seed)
    secretKeyHex = keygenHandle.secretKeyHex


    newFragment = utl.hexXOR(secretKeyHex, splitterKeyHex)

    keygenHandle.keyTraceHex = newFragment
    keygenHandle.keySaltHex = keySaltHex

    # regeneratedKey = utl.hexXOR(keygenHandle.keyTraceHex, splitterKeyHex)
    # olog {
    #     regeneratedKey, 
    #     secretKeyHex
    # }
    return

############################################################
export useQrData = (data) ->
    log "useQrData #{data}"
    createKeyProtection(data)
    keygenHandle.protection = "qr"

    resetProtectionButtons()
    conclusionRow.classList.add("acceptable")
    qrProtectButton.classList.add("active")
    protectedIndicator.className = "qr-protected"
    return

export usePhraseData = (data) ->
    log "usePhraseData #{data}"
    createKeyProtection(data)
    keygenHandle.protection = "phrase"

    resetProtectionButtons()
    conclusionRow.classList.add("acceptable")
    phraseProtectButton.classList.add("active")
    protectedIndicator.className = "phrase-protected"
    return
