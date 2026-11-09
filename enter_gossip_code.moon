-- Adds Enter-key support to gossip code boxes so players can submit a code without clicking Accept.

AIO = AIO or require("AIO")

return if AIO.AddAddon

Server = AIO.AddHandler "AIO_TWEAKS_GOSSIP_CODE", {}

DefaultLocale = {
    enterValue: "Please enter a value."
}

Locale = {
    frFR: {
        enterValue: "Merci d'entrer une valeur."
    }
}

--- Returns the localized text for the active client locale.
---@param key string The localization key to look up.
---@return string The localized text, or the English fallback.
GetLocaleText = (key) ->
    locale = Locale[GetLocale!]
    if locale and locale[key]
        return locale[key]

    DefaultLocale[key]

--- Resets the gossip code popup and optionally closes the gossip window.
---@param with_close boolean Whether to close the gossip window.
ResetStaticPopup = (with_close) ->
    StaticPopupDialogs["GOSSIP_ENTER_CODE"].text = ENTER_CODE
    if (with_close)
        CloseGossip!

StaticPopupDialogs["GOSSIP_ENTER_CODE"].text = ENTER_CODE
StaticPopupDialogs["GOSSIP_ENTER_CODE"].button1 = ACCEPT
StaticPopupDialogs["GOSSIP_ENTER_CODE"].button2 = CANCEL
StaticPopupDialogs["GOSSIP_ENTER_CODE"].hasEditBox = 1

--- Validates the entered code and submits the selected gossip option.
---@param data number The gossip option identifier associated with this popup.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].OnAccept = (data) =>
    text = @editBox\GetText!
    if not text or text == ""
        UIErrorsFrame\AddMessage GetLocaleText("enterValue"), 1.0, 0.0, 0.0, 3
        ResetStaticPopup true
    else
        SelectGossipOption data, text, true

--- Closes the popup and restores the gossip window after cancellation.
---@param data number The gossip option identifier associated with this popup.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].OnCancel = (data) =>
    ResetStaticPopup true

--- Focuses the edit box when the popup is shown.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].OnShow = =>
    @editBox\SetFocus!

--- Restores chat focus and clears the edit box when the popup is hidden.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].OnHide = =>
    ChatEdit_FocusActiveWindow!
    @editBox\SetText ""
    ResetStaticPopup true

--- Validates and submits the code when Enter is pressed in the edit box.
---@param data number The gossip option identifier associated with this popup.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].EditBoxOnEnterPressed = (data) =>
    parent = @GetParent!
    text = parent.editBox\GetText!
    if not text or text == ""
        UIErrorsFrame\AddMessage GetLocaleText("enterValue"), 1.0, 0.0, 0.0, 3
        ResetStaticPopup true
    else
        SelectGossipOption data, text, true
        parent\Hide!

--- Hides the popup when Escape is pressed in the edit box.
StaticPopupDialogs["GOSSIP_ENTER_CODE"].EditBoxOnEscapePressed = =>
    @GetParent!\Hide!

StaticPopupDialogs["GOSSIP_ENTER_CODE"].timeout = 0
StaticPopupDialogs["GOSSIP_ENTER_CODE"].exclusive = 1
StaticPopupDialogs["GOSSIP_ENTER_CODE"].hideOnEscape = 1
