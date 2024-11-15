script_name("Truck Helper")
script_author("@TelefonRedmi12c")
script_version("1.3")
----------------- [Библиотеки] ---------------------------
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new
require 'lib.moonloader'
local ffi = require 'ffi'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local faicons = require('fAwesome6')
local VersionV = '1.3'

local boxing = 0
local zarplatas = 0
local reys = 0
local tab = 0
local OilMenu = new.bool(false)
local WinState = new.bool(false)
local WinState2 = new.bool(false)
local weight = 'не пройдено'
local direct = 'Неизвестно'

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    imgui.Text(u8(text))
end


local ini = inicfg.load({
    cfg ={
        time = 0,
        vremena = false,
        innavigator = false,
        skipdialogi = false,
        invzvesh = false,
        zarplata = false,
        larci = false,
        reisi = false,
        eatmaso = false, 
    },
    knopa = {
        pochinka = false,   
        fillcar = false,   
        dveri = false,   
        key = false,
        rejim = false,
		domk  = false,
		door = false,
    }
}, "dbhelpeer.ini")

local pochinka = imgui.new.bool(ini.knopa.pochinka)	
local fillcar = imgui.new.bool(ini.knopa.fillcar)
local dveri = imgui.new.bool(ini.knopa.dveri)	
local key = imgui.new.bool(ini.knopa.key)
local rejim = imgui.new.bool(ini.knopa.rejim)
local domk = imgui.new.bool(ini.knopa.domk)
local door = imgui.new.bool(ini.knopa.door)
time = new.int(ini.cfg.time)
local timeStatus = false

local skipdialogi = imgui.new.bool(ini.cfg.skipdialogi)
local vremena = imgui.new.bool(ini.cfg.vremena)
local invzvesh = imgui.new.bool(ini.cfg.invzvesh)
local innavigator = imgui.new.bool(ini.cfg.innavigator)
local zarplata = imgui.new.bool(ini.cfg.zarplata)
local eatmaso = new.bool(ini.cfg.eatmaso)
local larci = imgui.new.bool(ini.cfg.larci)
local reisi = imgui.new.bool(ini.cfg.reisi)
local infobarik = imgui.new.bool(false)

local infobarik2 = imgui.new.bool(false)

imgui.OnFrame(function() return WinState2[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin('##2Window', WinState2, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize) 
    
        if ini.knopa.pochinka then
            if imgui.Button(u8'Починка') then 
                sampSendChat('/repcar')
            end
        end 
        imgui.SameLine()
        if ini.knopa.fillcar then
            if imgui.Button(u8'Заправка') then 
                sampSendChat('/fillcar')
            end
        end
        imgui.SameLine() 
        if ini.knopa.key then
            if imgui.Button(u8'Ключи') then 
                sampSendChat('/key')
            end
        end
        imgui.SameLine() 
        if ini.knopa.dveri then
            if imgui.Button(u8'Двери') then 
                sampSendChat('/lock')
            end
        end
                imgui.SameLine()
         if ini.knopa.rejim then
            if imgui.Button(u8' Режим') then 
                sampSendChat('/style')
            end
        end
        imgui.SameLine()
         if ini.knopa.domk then
            if imgui.Button(u8' Домкрат') then 
                sampSendChat('/domkrat')
            end
        end
        imgui.SameLine()
         if ini.knopa.door then
            if imgui.Button(u8' Открытие дверей') then 
                sampSendChat('/opengate')
            end
        end
    imgui.End()
end)

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin('##Window', WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize) 
        if ini.cfg.vremena then
            imgui.CenterText(get_clock(time[0]))
        end
        if ini.cfg.zarplata then
            imgui.Text(faicons('circle_dollar')..u8' Зарплата: '  ..separator(zarplatas).. '$') 
        end 
        if ini.cfg.larci then
            imgui.Text(faicons('box')..u8' Ларцов: ' ..boxing.. 'шт') 
        end
        if ini.cfg.reisi then
            imgui.Text(faicons('road')..u8' Рейсов: ' ..reys) 
        end
        if ini.cfg.innavigator then
        imgui.Text(faicons('road')..u8' Навигатор: '..u8(direct))
        end
        if ini.cfg.invzvesh then
        imgui.Text(faicons('truck_ramp_box')..u8' Взвешивание: '..u8(weight))
        end
    imgui.End()
end)


local navigator = {
    x = {
        {1484,'Лас Вентурас - Диллимор'},
        {1476,'Лас Вентурас - Ангел Пайн'},
        {2166,'Лос Сантос - Ангел Пайн'},
        {2227,'Лос Сантос - Лас Пайсадас'}
    },
    y = {
        {304,'Cан Фиерро - Лас Пайсадас'},
        {233,'Cан Фиерро - Диллимор'}
    }
}

function sampev.onSetRaceCheckpoint(type, position, nextPosition, size)
    for index,id in pairs(navigator.x) do
        if math.floor(position.x) == id[1] then
            direct = id[2]
        end
    end
    for index,id in pairs(navigator.y) do
        if math.floor(position.y) == id[1] then
            direct = id[2]
        end
    end
end

function sampev.onServerMessage(color, text)
    if text:find("Взвешивание завершено..") then
        weight = 'пройдено'
    end
    if text:find("Вам был добавлен предмет 'Ларец дальнобойщика'") then
        boxing = boxing + 1
    end
    if text:find('Ваша зарплата за рейс: $(%d+)') then	    
        local salary = text:match('Ваша зарплата за рейс: $(%d+)')
        zarplatas = zarplatas + salary
        reys = reys + 1
        weight = 'не пройдено'
    end
    if text:find('Благодаря улучшениям вашей семьи вы получаете дополнительную зарплату: $(%d+).') then	    
        local famzp = text:match('Благодаря улучшениям вашей семьи вы получаете дополнительную зарплату: $(%d+).')
        zarplatas = zarplatas + famzp
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 15558 and skipdialogi[0] then sampSendDialogResponse(15558,1,-1,-1) return false end
    if id == 15508 and skipdialogi[0] then sampSendDialogResponse(15508,1,-1,-1)  return false end
    end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solmyID'), 14, config, iconRanges)
end)

function sampev.onSendSpawn()
sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Скрипт загружен', -1)
sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Автор: @TelefonRedmi12c', -1)
sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Активация: /db', -1)
sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Версия: 1.3', -1)
end


imgui.OnFrame(function() return OilMenu[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(1000,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('db Helper', OilMenu)
        if imgui.Button(u8' Информация', imgui.ImVec2(260, 45)) then tab = 1 end
        if imgui.Button(u8' Настройка инфобара', imgui.ImVec2(260, 45)) then tab = 2 end
        if imgui.Button(u8' Настройка хелпбара', imgui.ImVec2(260, 45)) then tab = 3 end
                if imgui.Button(u8'Основные настройки', imgui.ImVec2(260, 45)) then tab = 4 end
        
        imgui.SetCursorPos(imgui.ImVec2(265, 33))
        if imgui.BeginChild('Name', imgui.ImVec2(-1, -1), true) then

            if tab == 1 then 
                imgui.Text(u8'Truck Helper - Создан для помощи в роботе Дальнобойщиков Arizona Mobile.')
                imgui.Text(u8'Версия: ' ..VersionV)
                imgui.Text(u8'Автор: @TelefonRedmi12c')                  
				imgui.Text(u8'Обновил: @Medvedeev4')                    
                
                imgui.Separator()
	if imgui.Button(u8" Перезагрузить") then script_reload() end
	imgui.SameLine()
	if imgui.Button(u8" Выгрузить") then script_unload() end
                
            elseif tab == 2 then
                if imgui.Checkbox(u8'Отображение инфобара',infobarik) then
                    WinState[0]= not WinState[0]              
                end
                if imgui.Checkbox(u8'Отображение секундомера',vremena) then
                    ini.cfg.vremena = vremena[0]
                    cfg_save() 
                end 
    
                if imgui.Checkbox(u8'Отображение зарплаты',zarplata) then
                    ini.cfg.zarplata = zarplata[0]
                    cfg_save() 
                end 
                                                                
                if imgui.Checkbox(u8'Отображение ларцов',larci) then 
                    ini.cfg.larci = larci[0]
                    cfg_save() 
                end
                                                        
                if imgui.Checkbox(u8'Отображение рейсов',reisi) then 
                    ini.cfg.reisi = reisi[0]
                    cfg_save() 
                end     
                if imgui.Checkbox(u8'Отображение навигатора',innavigator) then 
                    ini.cfg.innavigator = innavigator[0]
                    cfg_save() 
                end   
                 if imgui.Checkbox(u8'Отображение взвешивания',invzvesh) then 
                    ini.cfg.invzvesh = invzvesh[0]
                    cfg_save() 
                end   
        if imgui.Button(u8'Секундомер вкл/выкл') then
            tstate()
        end   
        imgui.SameLine() 
if imgui.Button(u8' Очистить секундомер') then
resetCounter()
end   
imgui.SameLine()      
        if imgui.Button(u8'Очистить всё') then
    deleteAll()
end
            elseif tab == 3 then        
                if imgui.Checkbox(u8'Отображение инфобара',infobarik2) then
                    WinState2[0]= not WinState2[0]              
                end     
                if imgui.Checkbox(u8'Отображение кнопки [ Починка ] ',pochinka) then
                    ini.knopa.pochinka = pochinka[0]
                    cfg_save() 
                end 
                
                if imgui.Checkbox(u8'Отображение кнопки [ Заправка ] ',fillcar) then
                    ini.knopa.fillcar = fillcar[0]
                    cfg_save() 
                end 
                
                if imgui.Checkbox(u8'Отображение кнопки [ Ключи ] ',key) then
                    ini.knopa.key = key[0]
                    cfg_save() 
               end
                    
                if imgui.Checkbox(u8'Отображение кнопки [ Двери ] ',dveri) then
                    ini.knopa.dveri = dveri[0]
                    cfg_save()
               end
               
                if imgui.Checkbox(u8'Отображение кнопки [ Режим ] ',rejim) then
                    ini.knopa.rejim = rejim[0]
                    cfg_save() 
                end
                
                if imgui.Checkbox(u8'Отображение кнопки [ Домкрат ] ',domk) then
                    ini.knopa.domk = domk[0]
                    cfg_save() 
                end
                
                if imgui.Checkbox(u8'Отображение кнопки [ Открытие дверей ] ',door) then
                    ini.knopa.door = door[0]
                    cfg_save() 
                end
                
                elseif tab == 4 then 
                if imgui.Checkbox(u8'Скип лишних диалогов',skipdialogi) then
          ini.knopa.skipdialogi = skipdialogi[0]      sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Теперь у вас' .. (skipdialogi[0] and ' автоматически будут скипаться диалоги.' or ' не будут автоматически скипаться диалоги.'), -1)
                    cfg_save() 
                end 
                         
     
            if imgui.Checkbox(u8'Авто еда на мясо',eatmaso) then sampAddChatMessage('{00F0D1}[Truck Helper]: {00F0D1}Теперь вы' .. (eatmaso[0] and ' будете автоматически съедать мясо.' or ' не будете автоматически съедать мясо.'), -1)
                    ini.cfg.eatmaso = eatmaso[0]
                    cfg_save() 
                end                              
            end
            
        imgui.EndChild() end 
    imgui.End()
end)

function deleteAll()
    --и тут всё что нужно
    reys = 0
    boxing = 0
    zarplatas = 0
end



function cfg_save()
    inicfg.save(ini, "dbhelpeer.ini")
end

function main()
    while not isSampAvailable() do wait(0) end
    lua_thread.create(counter)
    sampRegisterChatCommand('db', function() OilMenu[0] = not OilMenu[0] end)
 
    wait(-1)
end

imgui.OnInitialize(function()
    imgui.DarkTheme()
end)

function counter()
    while true do
        wait(1000)
		if timeStatus then
            time[0] = time[0] + 1
            ini.cfg.time = time[0]
            cfg_save()
        end
    end
end     

function tstate()
    timeStatus = not timeStatus
end

function resetCounter()
	ini.cfg.time = 0
	timeStatus = false
    cfg_save()
    time[0] = ini.cfg.time
end

function separator(n)
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end
function script_reload()
lua_thread.create(function()
sampAddChatMessage("{00F0D1}[Truck Helper]: {00F0D1}Скрипт будет перезагружен через 1 секунду!", -1)
wait(1000)
sampAddChatMessage("{00F0D1}[Truck Helper]: {00F0D1}Перезагрузка...", -1)
thisScript():reload()
end)
end

function script_unload()
lua_thread.create(function()
sampAddChatMessage("{00F0D1}[Truck Helper]: {00F0D1}Скрипт будет выгружен через 1 секунду!", -1)
wait(1000)
sampAddChatMessage("{00F0D1}[Truck Helper]: {00F0D1}Выгрузка...", -1)
thisScript():unload()
end)
end

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 0
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 2
    imgui.GetStyle().ChildBorderSize = 2
    imgui.GetStyle().PopupBorderSize = 2
    imgui.GetStyle().FrameBorderSize = 2
    imgui.GetStyle().TabBorderSize = 2
     
	 --==[ OTHER ]==--
    function sampev.onDisplayGameText(style, time, text)
	if text:find('You are hungry!') or text:find('You are very hungry!') then
	if ini.cfg.eatmaso then
sampSendChat("/eat")
sampSendDialogResponse(9965, 1, 3, nil)
end
end
end 

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
if ini.cfg.eatmaso then
if dialogId == 9965 then
sampSendDialogResponse(9965, 1, 3, 0)
end
end
end
    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 10
    imgui.GetStyle().ChildRounding = 2
    imgui.GetStyle().FrameRounding =2
    imgui.GetStyle().PopupRounding = 2
    imgui.GetStyle().ScrollbarRounding = 2
    imgui.GetStyle().GrabRounding = 2
    imgui.GetStyle().TabRounding = 2

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end