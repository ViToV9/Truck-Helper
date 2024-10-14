script_name("Truck Helper")
script_author("@TelefonRedmi12c")
script_version("2.0")
----------------- [Library] ---------------------------
local sampev = require("samp.events")
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new
require 'lib.moonloader'
local ffi = require 'ffi'
local inicfg = require 'inicfg'
local fa = require("fAwesome6")
local gta = ffi.load("GTASA")
local sizeX, sizeY = getScreenResolution()
local monet = require 'MoonMonet'
local filter = imgui.ImGuiTextFilter() 
local ltn12 = require("ltn12")
local http = require("socket.http")
local sf = require 'sampfuncs'
local iniFile = 'Truck HelperConfig.ini'


local VersionV = '2.0'
local boxing = 0
local zarplatas = 0
local reys = 0
local tab = 0
local OilMenu = new.bool(false)
local LogMenu = new.bool()
local WinState = new.bool(false)
local WinState2 = new.bool(false)
local weight = 'РЅРµ РїСЂРѕР№РґРµРЅРѕ'
local direct = 'РќРµРёР·РІРµСЃС‚РЅРѕ'

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
    },	
    	theme = {
        moonmonet = (759410733)
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

if not doesDirectoryExist(getWorkingDirectory()..'\\config') then print('Creating the config directory') createDirectory(getWorkingDirectory()..'\\config') end
if not doesFileExist('monetloader/config/'..iniFile) then print('Creating/updating the .ini file') inicfg.save(ini, iniFile) end

local lmPath = "Truck Helper.lua"
local lmUrl = "https://github.com/ViToV9/Truck-Helper/raw/refs/heads/main/Truck%20Helper.lua"
function downloadFile(url, path)

    local response = {}
    local _, status_code, _ = http.request{
      url = url,
      method = "GET",
      sink = ltn12.sink.file(io.open(path, "w")),
      headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0;Win64) AppleWebkit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
  
      },
    }
  
    if status_code == 200 then
      return true
    else
      return false
    end
  end
  
function check_update()
    sampAddChatMessage(u8'РџСЂРѕРІРµСЂРєР° РЅР°Р»РёС‡РёСЏ РѕР±РЅРѕРІР»РµРЅРёР№...', -1)
    local currentVersionFile = io.open(lmPath, "r")
    local currentVersion = currentVersionFile:read("*a")
    currentVersionFile:close()
    local response = http.request(lmUrl)
    if response and response ~= currentVersion then
        sampAddChatMessage( u8"РЈ РІР°СЃ РЅРµ Р°РєС‚СѓР°Р»СЊРЅР°СЏ РІРµСЂСЃРёСЏ! Р”Р»СЏ РѕР±РЅРѕРІР»РµРЅРёСЏ РїРµСЂРµР№РґРёС‚Рµ РІРѕ РІРєР»Р°РґРєСѓ: РРЅС„РѕСЂРјР°С†РёСЏ", -1)
    else
        sampAddChatMessage( u8"РЈ РІР°СЃ Р°РєС‚СѓР°Р»СЊРЅР°СЏ РІРµСЂСЃРёСЏ СЃРєСЂРёРїС‚Р°.", -1)
    end
end
local function updateScript(scriptUrl, scriptPath)
    sampAddChatMessage(u8"РџСЂРѕРІРµСЂРєР° РЅР°Р»РёС‡РёСЏ РѕР±РЅРѕРІР»РµРЅРёР№...", -1)
    local response = http.request(scriptUrl)
    if response and response ~= currentVersion then
        sampAddChatMessage(u8"Р”РѕСЃС‚СѓРїРЅР° РЅРѕРІР°СЏ РІРµСЂСЃРёСЏ СЃРєСЂРёРїС‚Р°! РћР±РЅРѕРІР»РµРЅРёРµ...", -1)
        
        local success = downloadFile(scriptUrl, scriptPath)
        if success then
            sampAddChatMessage(u8"РЎРєСЂРёРїС‚ СѓСЃРїРµС€РЅРѕ РѕР±РЅРѕРІР»РµРЅ.", -1)
            thisScript():reload()
        else
            sampAddChatMessage(u8"РќРµ СѓРґР°Р»РѕСЃСЊ РѕР±РЅРѕРІРёС‚СЊ СЃРєСЂРёРїС‚.", -1)
        end
    else
        sampAddChatMessage(u8"РЎРєСЂРёРїС‚ СѓР¶Рµ СЏРІР»СЏРµС‚СЃСЏ РїРѕСЃР»РµРґРЅРµР№ РІРµСЂСЃРёРµР№.", -1)
    end
end

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
local larci = imgui.new.bool(ini.cfg.larci)
local reisi = imgui.new.bool(ini.cfg.reisi)
local infobarik = imgui.new.bool(false)

imgui.OnInitialize(function()
    local tmp = imgui.ColorConvertU32ToFloat4(ini.theme['moonmonet'])
  gen_color = monet.buildColors(ini.theme.moonmonet, 1.0, true)
  mmcolor = imgui.new.float[3](tmp.z, tmp.y, tmp.x)
  apply_n_t()
end)

function show_arz_notify(type, title, text, time)
    if MONET_VERSION ~= nil then
        if type == 'info' then
            type = 3
        elseif type == 'error' then
            type = 2
        elseif type == 'success' then
            type = 1
        end
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 62)
        raknetBitStreamWriteInt8(bs, 6)
        raknetBitStreamWriteBool(bs, true)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
        local json = encodeJson({
            styleInt = type,
            title = title,
            text = text,
            duration = time
        })
        local interfaceid = 6
        local subid = 0
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 84)
        raknetBitStreamWriteInt8(bs, interfaceid)
        raknetBitStreamWriteInt8(bs, subid)
        raknetBitStreamWriteInt32(bs, #json)
        raknetBitStreamWriteString(bs, json)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
    else
        local str = ('window.executeEvent(\'event.notify.initialize\', \'["%s", "%s", "%s", "%s"]\');'):format(type, title, text, time)
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 17)
        raknetBitStreamWriteInt32(bs, 0)
        raknetBitStreamWriteInt32(bs, #str)
        raknetBitStreamWriteString(bs, str)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
    end
end

function separator(number)
    local formatted = tostring(number):reverse():gsub("%d%d%d", "%1 "):reverse()
    return formatted
end

function imgui.Ques(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.TextUnformatted(u8(text))
        imgui.EndTooltip()
    end
end

local infobarik2 = imgui.new.bool(false)
	
  
  
imgui.OnFrame(function() return WinState2[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(1000,600), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin('##2Window', WinState2, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize) 
    
        if ini.knopa.pochinka then
            if imgui.Button(fa.CAR_WRENCH .. u8' РџРѕС‡РёРЅС‚СЊ') then 
                sampSendChat('/repcar')
            end
        end
        
        if ini.knopa.fillcar then
            if imgui.Button(fa.GAS_PUMP .. u8' Р—Р°РїСЂР°РІРёС‚СЊ') then 
                sampSendChat('/fillcar')
            end
        end

        if ini.knopa.key then
            if imgui.Button(fa.KEY .. u8' РљР»СЋС‡Рё') then 
                sampSendChat('/key')
            end
        end
       
        if ini.knopa.dveri then
            if imgui.Button(fa.DOOR_OPEN .. u8' Р”РІРµСЂРё') then 
                sampSendChat('/lock')
            end
        end
         
         if ini.knopa.rejim then
            if imgui.Button(u8' Р РµР¶РёРј') then 
                sampSendChat('/style')
            end
        end
        
         if ini.knopa.domk then
            if imgui.Button(fa.BLINDS_RAISED .. u8' Р”РѕРјРєСЂР°С‚') then 
                sampSendChat('/domkrat')
            end
        end
        
         if ini.knopa.door then
            if imgui.Button(fa.DOOR_OPEN .. u8' РћС‚РєСЂС‹С‚РёРµ РґРІРµСЂРµР№') then 
                sampSendChat('/opengate')
            end
        end
    imgui.End()
end)

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(1000,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin('##Window', WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize) 
    
        if ini.cfg.vremena then
            imgui.CenterText(get_clock(time[0]))
        end
        
        if ini.cfg.zarplata then
            imgui.Text(fa.CIRCLE_DOLLAR .. u8'  Р—Р°СЂРїР»Р°С‚Р°: '  ..separator(zarplatas).. '$')
        end 
        
        if ini.cfg.larci then
            imgui.Text(fa.BOX .. u8' Р›Р°СЂС†РѕРІ: ' ..boxing.. 'С€С‚') 
        end
        
        if ini.cfg.reisi then
            imgui.Text(fa.ROAD .. u8' Р РµР№СЃРѕРІ: ' ..reys) 
        end
        
        if ini.cfg.innavigator then
        imgui.Text(fa.ROAD .. u8' РќР°РІРёРіР°С‚РѕСЂ: '..u8(direct))
        end
        
        if ini.cfg.invzvesh then
        imgui.Text(fa.TRUCK_RAMP_BOX .. u8' Р’Р·РІРµС€РёРІР°РЅРёРµ: '..u8(weight))
        end
    imgui.End()
end)


local navigator = {
    x = {
        {1484,'Р›Р°СЃ Р’РµРЅС‚СѓСЂР°СЃ - Р”РёР»Р»РёРјРѕСЂ'},
        {1476,'Р›Р°СЃ Р’РµРЅС‚СѓСЂР°СЃ - РђРЅРіРµР» РџР°Р№РЅ'},
        {2166,'Р›РѕСЃ РЎР°РЅС‚РѕСЃ - РђРЅРіРµР» РџР°Р№РЅ'},
        {2227,'Р›РѕСЃ РЎР°РЅС‚РѕСЃ - Р›Р°СЃ РџР°Р№СЃР°РґР°СЃ'}
    },
    y = {
        {304,'CР°РЅ Р¤РёРµСЂСЂРѕ - Р›Р°СЃ РџР°Р№СЃР°РґР°СЃ'},
        {233,'CР°РЅ Р¤РёРµСЂСЂРѕ - Р”РёР»Р»РёРјРѕСЂ'}
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
    if text:find("Р’Р·РІРµС€РёРІР°РЅРёРµ Р·Р°РІРµСЂС€РµРЅРѕ..") then
    show_arz_notify('success', ' Truck Helper', "Р’Р·РІРµС€РёРІР°РЅРёРµ РїСЂРѕР№РґРµРЅРѕ", 1000)
        weight = 'РїСЂРѕР№РґРµРЅРѕ'        
    end
    
    if text:find("Р’Р°Рј Р±С‹Р» РґРѕР±Р°РІР»РµРЅ РїСЂРµРґРјРµС‚ 'Р›Р°СЂРµС† РґР°Р»СЊРЅРѕР±РѕР№С‰РёРєР°'") then
        boxing = boxing + 1
        show_arz_notify('info', 'Truck Helper', "Р’Р°Рј Р±С‹Р» РґРѕР±Р°РІР»РµРЅ Р»Р°СЂРµС†", 1000)
    end
    if text:find('Р’Р°С€Р° Р·Р°СЂРїР»Р°С‚Р° Р·Р° СЂРµР№СЃ: $(%d+)') then	    
        local salary = text:match('Р’Р°С€Р° Р·Р°СЂРїР»Р°С‚Р° Р·Р° СЂРµР№СЃ: $(%d+)')
        zarplatas = zarplatas + salary
        reys = reys + 1
        weight = 'РЅРµ РїСЂРѕР№РґРµРЅРѕ'
    end
    if text:find('Р‘Р»Р°РіРѕРґР°СЂСЏ СѓР»СѓС‡С€РµРЅРёСЏРј РІР°С€РµР№ СЃРµРјСЊРё РІС‹ РїРѕР»СѓС‡Р°РµС‚Рµ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅСѓСЋ Р·Р°СЂРїР»Р°С‚Сѓ: $(%d+).') then	    
        local famzp = text:match('Р‘Р»Р°РіРѕРґР°СЂСЏ СѓР»СѓС‡С€РµРЅРёСЏРј РІР°С€РµР№ СЃРµРјСЊРё РІС‹ РїРѕР»СѓС‡Р°РµС‚Рµ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅСѓСЋ Р·Р°СЂРїР»Р°С‚Сѓ: $(%d+).')
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
    iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('light'), 29, config, iconRanges)
end)




function sampev.onSendSpawn()
sampAddChatMessage("{009EFF}[Truck Helper]: {FFFFFF}Р—Р°РіСЂСѓР·РєР° С…РµР»РїРµСЂР° РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ!", -1)
show_arz_notify('info', 'Truck Helper', "Р—Р°РіСЂСѓР·РєР° С…РµР»РїРµСЂР° РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ!", 3000)
print('[Truck Helper] Р—Р°РіСЂСѓР·РєР° С…РµР»РїРµСЂР° РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ!')
sampAddChatMessage("{009EFF}[Truck Helper]{FFFFFF}: Р§С‚РѕР± РѕС‚РєСЂС‹С‚СЊ РјРµРЅСЋ С…РµР»РїРµСЂР° РІРІРµРґРёС‚Рµ РєРѕРјР°РЅРґСѓ {009EFF}/db", -1)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

imgui.OnFrame(function() return OilMenu[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(fa.TRUCK .. ' Truck Helper', OilMenu, imgui.WindowFlags.NoCollapse)
    if imgui.BeginTabBar('Tabs') then
                  		           										  
        if imgui.BeginTabItem(fa.GEAR .. u8' РќР°СЃС‚СЂРѕР№РєРё РёРЅС„РѕР±Р°СЂР°') then
            
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РёРЅС„РѕСЂРјР°С†РёРё',infobarik) then
                    WinState[0]= not WinState[0]              
                end
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ СЃРµРєСѓРЅРґРѕРјРµСЂР°',vremena) then
                    ini.cfg.vremena = vremena[0]
                    cfg_save() 
                end 
    
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ Р·Р°СЂРїР»Р°С‚С‹',zarplata) then
                    ini.cfg.zarplata = zarplata[0]
                    cfg_save() 
                end 
                                                                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ Р»Р°СЂС†РѕРІ',larci) then 
                    ini.cfg.larci = larci[0]
                    cfg_save() 
                end
                                                        
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ СЂРµР№СЃРѕРІ',reisi) then 
                    ini.cfg.reisi = reisi[0]
                    cfg_save()
                end     
                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РЅР°РІРёРіР°С‚РѕСЂР°',innavigator) then 
                    ini.cfg.innavigator = innavigator[0]
                    cfg_save() 
                end   
                 if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РІР·РІРµС€РёРІР°РЅРёСЏ',invzvesh) then 
                    ini.cfg.invzvesh = invzvesh[0]
                    cfg_save() 
                end   
                imgui.Separator()
                if imgui.Checkbox(fa.FORWARD .. u8' РЎРєРёРї Р»РёС€РЅРёС… РґРёР°Р»РѕРіРѕРІ',skipdialogi) then         
          ini.knopa.skipdialogi = skipdialogi[0]      sampAddChatMessage('{009EFF}[Truck Helper]: {FFFFFF}РўРµРїРµСЂСЊ Сѓ РІР°СЃ' .. (skipdialogi[0] and ' Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё Р±СѓРґСѓС‚ СЃРєРёРїР°С‚СЊСЃСЏ Р»РёС€РЅРёРµ РґРёР°Р»РѕРіРё.' or ' РЅРµ Р±СѓРґСѓС‚ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё СЃРєРёРїР°С‚СЊСЃСЏ Р»РёС€РЅРёРµ РґРёР°Р»РѕРіРё.'), -1)        
                    cfg_save() 
                end                      
                imgui.Separator()
        if imgui.Button(u8'РЎРµРєСѓРЅРґРѕРјРµСЂ РІРєР»/РІС‹РєР»') then
            tstate()
        end   
        imgui.SameLine() 
if imgui.Button(u8' РћС‡РёСЃС‚РёС‚СЊ СЃРµРєСѓРЅРґРѕРјРµСЂ') then
resetCounter()
end   
imgui.SameLine()      
        if imgui.Button(u8'РћС‡РёСЃС‚РёС‚СЊ РІСЃС‘') then
    deleteAll()
            end
                                     
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem(fa.GEAR .. u8' РќР°СЃС‚СЂРѕР№РєРё С…РµР»РїР±Р°СЂР°') then
            
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРѕРє',infobarik2) then
                    WinState2[0]= not WinState2[0]              
                end     
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ РџРѕС‡РёРЅРєР° ] ',pochinka) then
                    ini.knopa.pochinka = pochinka[0]
                    cfg_save() 
                end 
                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ Р—Р°РїСЂР°РІРєР° ] ',fillcar) then
                    ini.knopa.fillcar = fillcar[0]
                    cfg_save() 
                end 
                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ РљР»СЋС‡Рё ] ',key) then
                    ini.knopa.key = key[0]
                    cfg_save() 
               end
                    
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ Р”РІРµСЂРё ] ',dveri) then
                    ini.knopa.dveri = dveri[0]
                    cfg_save()
               end
               
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ Р РµР¶РёРј ] ',rejim) then
                    ini.knopa.rejim = rejim[0]
                    cfg_save() 
                end
                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ Р”РѕРјРєСЂР°С‚ ] ',domk) then
                    ini.knopa.domk = domk[0]
                    cfg_save() 
                end
                
                if imgui.Checkbox(u8'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РєРЅРѕРїРєРё [ РћС‚РєСЂС‹С‚РёРµ РґРІРµСЂРµР№ ] ',door) then
                    ini.knopa.door = door[0]
                    cfg_save() 
                end
        
        imgui.EndTabItem()
    end 
    
    if imgui.BeginTabItem(fa.GEAR .. u8' РќР°СЃС‚СЂРѕР№РєРё') then
    			imgui.Separator()
   			 imgui.Separator()
    imgui.Text(fa.CIRCLE_USER..u8" Р Р°Р·СЂР°Р±РѕС‚С‡РёРє РґР°РЅРЅРѕРіРѕ С…РµР»РїРµСЂР°: TelefonRedmi12c")
				imgui.Separator()
				imgui.Text(fa.CIRCLE_INFO..u8' РЈСЃС‚Р°РЅРѕРІР»РµРЅРЅР°СЏ РІРµСЂСЃРёСЏ С…РµР»РїРµСЂР° ' .. VersionV)
		 		imgui.SameLine()
      if imgui.Button(u8' РћР±РЅРѕРІРёС‚СЊ') then
    updateScript(lmUrl, lmPath)
end
				imgui.Separator()
				imgui.Text(fa.HEADSET..u8" РўРµС….РїРѕРґРґРµСЂР¶РєР° РїРѕ С…РµР»РїРµСЂСѓ:")
				imgui.SameLine()
				if imgui.SmallButton('Telegram') then
					openLink('https://t.me/Jake_S2')
				end
				imgui.Separator()
				imgui.Text(fa.GLOBE..u8" РўРµРјР° С…РµР»РїРµСЂР° РЅР° С„РѕСЂСѓРјРµ BlastHack:")
				imgui.SameLine()
				if imgui.SmallButton(u8'https://www.blast.hk/threads/217684/') then
					openLink('https://www.blast.hk/threads/217684/')			
end
					imgui.Separator()
 					imgui.Separator()
            imgui.Text(fa.NOTE_STICKY..u8' Р¦РІРµС‚ MoonMonet ')          
            imgui.SameLine()
				if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
                r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
              argb = join_argb(0, r, g, b)
                ini.theme.moonmonet = argb
                cfg_save()
          apply_n_t()
            end
            
            
            imgui.Separator()
            imgui.Separator()
				imgui.CenterText(u8' РљРѕРјР°РЅРґС‹')
	imgui.Text(fa.CALCULATOR .. u8' /calc - РљР°Р»СЊРєСѓР»СЏС‚РѕСЂ')
                
						imgui.Separator()  
				      imgui.Separator()
	if imgui.Button(u8" РџРµСЂРµР·Р°РіСЂСѓР·РёС‚СЊ") then script_reload() end
	imgui.SameLine()
	if imgui.Button(u8" Р’С‹РіСЂСѓР·РёС‚СЊ") then script_unload() end
	imgui.Separator()
	imgui.Separator()
            							        
        imgui.EndTabItem()
        end
        imgui.EndTabBar()
    end
    imgui.End() 
end)           

function deleteAll()
    --Рё С‚СѓС‚ РІСЃС‘ С‡С‚Рѕ РЅСѓР¶РЅРѕ
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

sampRegisterChatCommand('calc', function(arg) 
        if #arg == 0 or not arg:find('%d+') then return sampAddChatMessage('[РљР°Р»СЊРєСѓР»СЏС‚РѕСЂ]: {DE9F00}РћС€РёР±РєР°, РІРІРµРґРёС‚Рµ /calc [РїСЂРёРјРµСЂ]', 0x08A351) end
        sampAddChatMessage('[Truck Helper]: {009EFF}'..arg..' = '..assert(load("return " .. arg))(), 0x08A351)
    end)

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'Рґ ' or '')..'%H:%M:%S', time + timezone_offset)
end

function script_reload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "РџРµСЂРµР·Р°РіСЂСѓР·РєР°....!", 500)
wait(0)
thisScript():reload()
end)
end

function script_unload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "Р’С‹РєР»СЋС‡РµРЅРёРµ....!", 500)
wait(0)
thisScript():unload()
end)
end

ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

function openLink(link)
    gta._Z12AND_OpenLinkPKc(link)
end

function apply_monet()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(15, 15)
    style.WindowRounding = 10.0
    style.ChildRounding = 6.0
    style.FramePadding = imgui.ImVec2(8, 7)
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2(8, 8)
    style.ItemInnerSpacing = imgui.ImVec2(10, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 25.0
    style.ScrollbarRounding = 12.0
    style.GrabMinSize = 10.0
    style.GrabRounding = 6.0
    style.PopupRounding = 8
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
  local generated_color = monet.buildColors(ini.theme.moonmonet, 1.0, true)
  colors[clr.Text] = ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
  colors[clr.TextDisabled] = ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
  colors[clr.WindowBg] = ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
  colors[clr.ChildBg] = ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
  colors[clr.PopupBg] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
  colors[clr.Border] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
  colors[clr.Separator] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
  colors[clr.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
  colors[clr.FrameBgHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
  colors[clr.FrameBgActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
  colors[clr.TitleBg] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
  colors[clr.TitleBgCollapsed] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
  colors[clr.TitleBgActive] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
  colors[clr.MenuBarBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
  colors[clr.ScrollbarBg] = imgui.ImVec4(0,0,0,0)
  colors[clr.ScrollbarGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
  colors[clr.ScrollbarGrabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.ScrollbarGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
  colors[clr.CheckMark] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
  colors[clr.SliderGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
  colors[clr.SliderGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
  colors[clr.Button] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
  colors[clr.ButtonHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.ButtonActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
  colors[clr.Tab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
  colors[clr.TabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
  colors[clr.TabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.Header] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
  colors[clr.HeaderHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.HeaderActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
  colors[clr.ResizeGrip] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
  colors[clr.ResizeGripHovered] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
  colors[clr.ResizeGripActive] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
  colors[clr.PlotLines] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
  colors[clr.PlotLinesHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.PlotHistogram] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
  colors[clr.PlotHistogramHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.TextSelectedBg] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
  colors[clr.ModalWindowDimBg] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
end

function apply_n_t()
    gen_color = monet.buildColors(ini.theme.moonmonet, 1.0, true)
    local a, r, g, b = explode_argb(gen_color.accent1.color_300)
  curcolor = '{'..rgb2hex(r, g, b)..'}'
    curcolor1 = '0x'..('%X'):format(gen_color.accent1.color_300)
    apply_monet()
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function rgb2hex(r, g, b)
    local hex = string.format("#%02X%02X%02X", r, g, b)
    return hex
end

function ColorAccentsAdapter(color)
    local a, r, g, b = explode_argb(color)
    local ret = {a = a, r = r, g = g, b = b}
    function ret:apply_alpha(alpha)
        self.a = alpha
        return self
    end
    function ret:as_u32()
        return join_argb(self.a, self.b, self.g, self.r)
    end
    function ret:as_vec4()
        return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
    end
    function ret:as_argb()
        return join_argb(self.a, self.r, self.g, self.b)
    end
    function ret:as_rgba()
        return join_argb(self.r, self.g, self.b, self.a)
    end
    function ret:as_chat()
        return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
    end
    return ret
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

local function ARGBtoRGB(color)
    return bit.band(color, 0xFFFFFF)
end
