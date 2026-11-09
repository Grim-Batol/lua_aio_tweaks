-- Adds a mailbox button that collects eligible mail money and attachments automatically.

AIO = AIO or require("AIO")

return if AIO.AddAddon

AIO.AddHandler "AIO_TWEAKS_POSTBOX_OPEN_ALL", {}

OPEN_ALL_MAIL_MIN_DELAY = 0.15
ATTACHMENTS_MAX = 16

DefaultLocale = {
    openAll: "Open all"
    opening: "Opening..."
    finished: "Finished"
}

Locale = {
    frFR: {
        openAll: "Tout ouvrir"
        opening: "Ouverture..."
        finished: "Terminé"
    }
}

--- Returns localized text for the active client locale, falling back to English.
---@param key string The localization key to look up.
---@return string The localized text.
GetLocaleText = (key) ->
    locale = Locale[GetLocale!]
    if locale and locale[key]
        return locale[key]

    DefaultLocale[key]

--- Counts empty slots in the backpack and equipped bags.
---@return number The total number of free bag slots.
CalculateTotalNumberOfFreeBagSlots = ->
    freeSlots = 0
    for bag = 0, 4
        slots = GetContainerFreeSlots bag
        freeSlots += #slots

    freeSlots

OpenAllMailMixin = {
    button: nil
    text: nil
    isStarted: false
    cooldown: 0
    mailIndex: 0
    attachmentIndex: ATTACHMENTS_MAX
}

--- Resets the inbox cursor and update timer.
OpenAllMailMixin.Reset = =>
    @cooldown = 0
    @mailIndex = GetInboxNumItems()
    @attachmentIndex = ATTACHMENTS_MAX

--- Starts collecting eligible mail from the current inbox.
OpenAllMailMixin.StartOpening = =>
    @Reset!
    @isStarted = true
    @button\Disable!
    @text\SetText GetLocaleText("opening")

--- Stops processing and restores the button.
OpenAllMailMixin.StopOpening = =>
    @isStarted = false
    @button\Enable!
    @Reset!
    @text\SetText GetLocaleText("finished")

--- Moves to the next eligible mail attachment or its money, skipping GM and COD mail.
---@return string|nil The next action type, or nil when no eligible mail remains.
OpenAllMailMixin.AdvanceToNextItem = =>
    while @mailIndex > 0
        _, _, _, _, money, codAmount, _, _, _, _, _, _, isGM = GetInboxHeaderInfo @mailIndex

        if isGM or (codAmount and codAmount > 0)
            @mailIndex -= 1
            @attachmentIndex = ATTACHMENTS_MAX
        elseif money and money > 0
            return "money"
        else
            while @attachmentIndex > 0
                if GetInboxItemLink(@mailIndex, @attachmentIndex)
                    return "item"

                @attachmentIndex -= 1

            @mailIndex -= 1
            @attachmentIndex = ATTACHMENTS_MAX

    nil

--- Collects one unit of mail contents, then waits for the next inbox update.
OpenAllMailMixin.ProcessNextItem = =>
    action = @AdvanceToNextItem!
    unless action
        @StopOpening!
        return

    if action == "money"
        TakeInboxMoney @mailIndex
    else
        if CalculateTotalNumberOfFreeBagSlots! == 0
            @StopOpening!
            return

        attachmentIndex = @attachmentIndex
        @attachmentIndex -= 1
        TakeInboxItem @mailIndex, attachmentIndex

    @cooldown = 0

--- Advances the inbox processing timer and collects mail when the delay expires.
OpenAllMailMixin.OnUpdate = (elapsed) =>
    return unless @isStarted

    @cooldown += elapsed
    return if @cooldown < OPEN_ALL_MAIL_MIN_DELAY

    @ProcessNextItem!

--- Creates the button used to collect eligible mail.
buttonOpenAll = CreateFrame "Button", "AioTweaks_OpenAllMailButton", MailFrame
buttonOpenAll\SetSize 115, 30
buttonOpenAll\SetPoint "CENTER", MailFrame, "BOTTOM", 0, 98
buttonOpenAll\SetNormalTexture "Interface/Buttons/ui-dialogbox-button-gold-up"
buttonOpenAll\SetHighlightTexture "Interface/Buttons/ui-dialogbox-button-highlight"
buttonOpenAll\SetPushedTexture "Interface/Buttons/ui-dialogbox-button-gold-down"

textOpenAll = buttonOpenAll\CreateFontString!
textOpenAll\SetFont "Fonts/FRIZQT__.TTF", 12
textOpenAll\SetPoint "CENTER", 0, 5
textOpenAll\SetText GetLocaleText("openAll")

OpenAllMailMixin.button = buttonOpenAll
OpenAllMailMixin.text = textOpenAll

buttonOpenAll\SetScript "OnClick", =>
    OpenAllMailMixin\StartOpening!

buttonOpenAll\SetScript "OnShow", =>
    textOpenAll\SetText GetLocaleText("openAll")

buttonOpenAll\SetScript "OnHide", =>
    if OpenAllMailMixin.isStarted
        OpenAllMailMixin\StopOpening!

buttonOpenAll\SetScript "OnUpdate", (elapsed) =>
    OpenAllMailMixin\OnUpdate elapsed
