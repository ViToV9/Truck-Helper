script_name("Truck Helper")
script_author("@TelefonRedmi12c // Jake")
script_version("2.1")
----------------- [����������] ---------------------------
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
local http = require("socket.http")
local ltn12 = require("ltn12")
local lfs = require("lfs")

local boxing = 0
local zarplatas = 0
local reys = 0
local tab = 0
local OilMenu = new.bool(false)
local WinState = new.bool(false)
local WinState2 = new.bool(false)
local weight = '�� ��������'
local direct = '����������'

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

local settings = {}
local default_settings = {
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
        moonmonet = (61951)
    },
    knopa = {
        pochinka = false,   
        fillcar = false,   
        dveri = false,   
        key = false,
        rejim = false,
		domk  = false,
    }
}
local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/Truck Helper"
local path = configDirectory .. "/Truck Helper.json"
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path) then
        settings = default_settings
		print('���� � ����������� �� ������, ��������� ����������� ���������!')
    else
        local file = io.open(path, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print(' �� ������� ������� ���� � �����������, ��������� ����������� ���������!')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
					for category, _ in pairs(default_settings) do
						if settings[category] == nil then
							settings[category] = {}
						end
						for key, value in pairs(default_settings[category]) do
							if settings[category][key] == nil then
								settings[category][key] = value
							end
						end
					end
					print('��������� ������� ���������!')
				else
					print('�� ������� ������� ���� � �����������, ��������� ����������� ���������!')
				end
			end
        else
            settings = default_settings
			print('�� ������� ������� ���� � �����������, ��������� ����������� ���������!')
        end
    end
end
function save()
    local file, errstr = io.open(path, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print(' ��������� ���������!')
        return result
    else
        print('�� ������� ��������� ��������� �������, ������: ', errstr)
        return false
    end
end
load_settings()

local pochinka = imgui.new.bool(settings.knopa.pochinka)	
local fillcar = imgui.new.bool(settings.knopa.fillcar)
local dveri = imgui.new.bool(settings.knopa.dveri)	
local key = imgui.new.bool(settings.knopa.key)
local rejim = imgui.new.bool(settings.knopa.rejim)
local domk = imgui.new.bool(settings.knopa.domk)
time = new.int(settings.cfg.time)
local skipdialogi = imgui.new.bool(settings.cfg.skipdialogi)
local vremena = imgui.new.bool(settings.cfg.vremena)
local invzvesh = imgui.new.bool(settings.cfg.invzvesh)
local innavigator = imgui.new.bool(settings.cfg.innavigator)
local zarplata = imgui.new.bool(settings.cfg.zarplata)
local larci = imgui.new.bool(settings.cfg.larci)
local reisi = imgui.new.bool(settings.cfg.reisi)
local infobarik = imgui.new.bool(false)
local timeStatus = false

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
    msg("�������� ������� ����������...")
    local currentVersionFile = io.open(lmPath, "r")
    local currentVersion = currentVersionFile:read("*a")
    currentVersionFile:close()
    local response = http.request(lmUrl)
    if response and response ~= currentVersion then
        msg("� ��� �� ���������� ������! ��� ���������� ��������� �� �������: ����������")
    else
        msg("� ��� ���������� ������ �������.")
    end
end
local function updateScript(scriptUrl, scriptPath)
    msg("�������� ������� ����������...")
    local response = http.request(scriptUrl)
    if response and response ~= currentVersion then
        msg("�������� ����� ������ �������! ����������...")
        
        local success = downloadFile(scriptUrl, scriptPath)
        if success then
            msg("������ ������� ��������.")
            thisScript():reload()
        else
            msg("�� ������� �������� ������.")
        end
    else
        msg("������ ��� �������� ��������� �������.")
    end
end

function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() -- ������ ��������� ����
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count) -- �������� ������� ������ �� ����������
end

imgui.OnInitialize(function()
    local tmp = imgui.ColorConvertU32ToFloat4(settings.theme['moonmonet'])
  gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
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
    
        if settings.knopa.pochinka then
            if imgui.Button(fa.CAR_WRENCH .. u8' �������') then 
                sampSendChat('/repcar')
            end
        end
        
        if settings.knopa.fillcar then
            if imgui.Button(fa.GAS_PUMP .. u8' ���������') then 
                sampSendChat('/fillcar')
            end
        end

        if settings.knopa.key then
            if imgui.Button(fa.KEY .. u8' �����') then 
                sampSendChat('/key')
            end
        end
       
        if settings.knopa.dveri then
            if imgui.Button(fa.DOOR_OPEN .. u8' �����') then 
                sampSendChat('/lock')
            end
        end
         
         if settings.knopa.rejim then
            if imgui.Button(u8' �����') then 
                sampSendChat('/style')
            end
        end
        
         if settings .knopa.domk then
            if imgui.Button(fa.BLINDS_RAISED .. u8' �������') then 
                sampSendChat('/domkrat')
            end
        end
                
    imgui.End()
end)

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(1000,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin('##Window', WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize) 
    
        if settings.cfg.vremena then
            imgui.CenterText(get_clock(time[0]))
        end
        
        if settings.cfg.zarplata then
            imgui.Text(fa.CIRCLE_DOLLAR .. u8'  ��������: '  ..separator(zarplatas).. '$')
        end 
        
        if settings.cfg.larci then
            imgui.Text(fa.BOX .. u8' ������: ' ..boxing.. '��') 
        end
        
        if settings.cfg.reisi then
            imgui.Text(fa.ROAD .. u8' ������: ' ..reys) 
        end
        
        if settings.cfg.innavigator then
        imgui.Text(fa.ROAD .. u8' ���������: '..u8(direct))
        end
        
        if settings.cfg.invzvesh then
        imgui.Text(fa.TRUCK_RAMP_BOX .. u8' �����������: '..u8(weight))
        end
    imgui.End()
end)


local navigator = {
    x = {
        {1484,'��� �������� - ��������'},
        {1476,'��� �������� - ����� ����'},
        {2166,'��� ������ - ����� ����'},
        {2227,'��� ������ - ��� ��������'}
    },
    y = {
        {304,'C�� ������ - ��� ��������'},
        {233,'C�� ������ - ��������'}
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
    if text:find("����������� ���������..") then
        weight = '��������'
    end
    if text:find("��� ��� �������� ������� '����� �������������'") then
        boxing = boxing + 1
    end
    if text:find('���� �������� �� ����: $(%d+)') then	    
        local salary = text:match('���� �������� �� ����: $(%d+)')
        zarplatas = zarplatas + salary
        reys = reys + 1
        weight = '�� ��������'
    end
    if text:find('��������� ���������� ����� ����� �� ��������� �������������� ��������: $(%d+).') then	    
        local famzp = text:match('��������� ���������� ����� ����� �� ��������� �������������� ��������: $(%d+).')
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

function main()
if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
lua_thread.create(counter)
msg("�������� ������� ������ �������!")
show_arz_notify('info', 'Truck Helper', "�������� ������� ������ �������!", 3000)
print(' �������� ������� ������ �������!')
msg("���� ������� ���� ������� ������� ������� {009EFF}/db")
check_update()
sampRegisterChatCommand('db', function() OilMenu[0] = not OilMenu[0] end)
end


imgui.OnFrame(function() return OilMenu[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 315	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
    imgui.Begin(fa.TRUCK .. ' Truck Helper', OilMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
    if imgui.BeginTabBar('Tabs') then			  
        if imgui.BeginTabItem(fa.GEAR .. u8' ��������� ��������') then
        imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 248 * MONET_DPI_SCALE), true)		
            
                if imgui.Checkbox(u8'����������� ����������',infobarik) then
                    WinState[0]= not WinState[0]              
                end
                if imgui.Checkbox(u8'����������� �����������',vremena) then
                    settings.cfg.vremena = vremena[0]
                    save() 
                end
    
                if imgui.Checkbox(u8'����������� ��������',zarplata) then
                    settings.cfg.zarplata = zarplata[0]
                    save() 
                end 
                                                                
                if imgui.Checkbox(u8'����������� ������',larci) then 
                    settings.cfg.larci = larci[0]
                    save() 
                end
                                                        
                if imgui.Checkbox(u8'����������� ������',reisi) then 
                    settings.cfg.reisi = reisi[0]
                    save() 
                end     
                if imgui.Checkbox(u8'����������� ����������',innavigator) then 
                    settings.cfg.innavigator = innavigator[0]
                    save() 
                end   
                 if imgui.Checkbox(u8'����������� �����������',invzvesh) then 
                    settings.cfg.invzvesh = invzvesh[0]
                    save() 
                end   
                imgui.Separator()
                if imgui.Checkbox(fa.FORWARD .. u8' ���� ������ ��������',skipdialogi) then         
          settings.knopa.skipdialogi = skipdialogi[0]      msg('������ � ���' .. (skipdialogi[0] and ' ������������� ����� ��������� ������ �������.' or ' �� ����� ������������� ��������� ������ �������.'))        
                    save() 
                end                      
                imgui.Separator()
        if imgui.Button(u8'���������� ���/����') then
            tstate()
        end   
        imgui.SameLine() 
if imgui.Button(u8' �������� ����������') then
resetCounter()
end   
imgui.SameLine()      
        if imgui.Button(u8'�������� ��') then
    deleteAll()
            end
                 
               imgui.EndChild()		     
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem(fa.GEAR .. u8' ��������� ��������') then
        imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 186 * MONET_DPI_SCALE), true)
            
                if imgui.Checkbox(u8'����������� ������',infobarik2) then
                    WinState2[0]= not WinState2[0]              
                end     
                if imgui.Checkbox(u8'����������� ������ [ ������� ] ',pochinka) then
                    settings.knopa.pochinka = pochinka[0]
                    save() 
                end 
                
                if imgui.Checkbox(u8'����������� ������ [ �������� ] ',fillcar) then
                    settings.knopa.fillcar = fillcar[0]
                    save() 
                end 
                
                if imgui.Checkbox(u8'����������� ������ [ ����� ] ',key) then
                    settings.knopa.key = key[0]
                    save() 
               end
                    
                if imgui.Checkbox(u8'����������� ������ [ ����� ] ',dveri) then
                    settings.knopa.dveri = dveri[0]
                    save()
               end
               
                if imgui.Checkbox(u8'����������� ������ [ ����� ] ',rejim) then
                    settings.knopa.rejim = rejim[0]
                    save() 
                end
                
                if imgui.Checkbox(u8'����������� ������ [ ������� ] ',domk) then
                    settings.knopa.domk = domk[0]
                    save() 
                end
                                                
        imgui.EndChild()		
        imgui.EndTabItem()
    end 
    
    if imgui.BeginTabItem(fa.INFO .. u8' ����������') then
    
imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 117 * MONET_DPI_SCALE), true)
    imgui.CenterText(fa.CIRCLE_INFO .. u8' �������������� ���������� ��� ������')
    imgui.Separator()
    
    imgui.Text(fa.CIRCLE_USER..u8" ����������� ������� �������: TelefonRedmi12c // Jake")
				imgui.Separator()
				imgui.Text(fa.CIRCLE_INFO..u8' ������������� ������ ������� ' .. thisScript().version)
				imgui.SameLine()
			if imgui.SmallButton(u8' ��������') then
    updateScript(lmUrl, lmPath)
end
				
				imgui.Separator()
				imgui.Text(fa.HEADSET..u8" ���.��������� �� �������:")
				imgui.SameLine()
				if imgui.SmallButton('Telegram') then
					openLink('https://t.me/Jake_S2')
				end
				imgui.Separator()
				imgui.Text(fa.GLOBE..u8" ���� ������� �� ������ BlastHack:")
				imgui.SameLine()
				if imgui.SmallButton(u8'https://www.blast.hk/threads/217684/') then
					openLink('https://www.blast.hk/threads/217684/')							
end
				imgui.EndChild()					
 imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 87 * MONET_DPI_SCALE), true)
				imgui.CenterText(fa.PALETTE .. u8' �������� ���� �������:')
				imgui.Separator()
				if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
                r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
              argb = join_argb(0, r, g, b)
                settings.theme.moonmonet = argb
                save()
          apply_n_t()
            end
            imgui.SameLine()
            imgui.Text(fa.NOTE_STICKY..u8' ���� MoonMonet') 
                   
					imgui.EndChild()
					imgui.BeginChild("##4",imgui.ImVec2(589 * MONET_DPI_SCALE, 42 * MONET_DPI_SCALE),true)
	if imgui.Button(fa.ROTATE_RIGHT .. u8" ������������ ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
reload_script = true
script_reload()
 end
	imgui.SameLine()
	if imgui.Button(fa.ROTATE_RIGHT .. u8" ��������� ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * MONET_DPI_SCALE)) then
reload_script = true
script_unload() 
end
            		
					        
        imgui.EndTabItem()
        end
        imgui.EndTabBar()
    end
    imgui.End() 
end)  

function deleteAll()
    --� ��� �� ��� �����
    reys = 0
    boxing = 0
    zarplatas = 0
end

function iniSave()
	settings.cfgtheme.theme = theme[0]
	inicfg.save(ini, iniFile)
end


function counter()
    while true do
        wait(1000)
        if timeStatus then
            time[0] = time[0] + 1
            settings.cfg.time = time[0]
            save()
        end
    end
end

function tstate()
    timeStatus = not timeStatus
end

function resetCounter()
    settings.cfg.time = 0
    timeStatus = false
    save()
    time[0] = settings.cfg.time
end

sampRegisterChatCommand('calc', function(arg) 
        if #arg == 0 or not arg:find('%d+') then return sampAddChatMessage('[�����������]: {DE9F00}������, ������� /calc [������]', 0x08A351) end
        sampAddChatMessage('[Truck Helper]: {009EFF}'..arg..' = '..assert(load("return " .. arg))(), 0x08A351)
    end)

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'� ' or '')..'%H:%M:%S', time + timezone_offset)
end

function script_reload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "������������....!", 500)
wait(0)
thisScript():reload()
end)
end

function script_unload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "����������....!", 500)
wait(0)
thisScript():unload()
end)
end

function msg(message)
    sampAddChatMessage("[Truck Helper]: {ffffff}".. message, 0x009EFF)
end

function sampev.onShowTextDraw(id, data)
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		msg('{ffffff}����������� ����� ���� Sport!')
		return false
	end
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		msg('{ffffff}����������� ����� ���� Comfort!')
		return false
	end
end
function sampev.onDisplayGameText(style,time,text)
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		msg('{ffffff}����������� ����� ���� Sport!')
		return false
	end
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		msg('{ffffff}����������� ����� ���� Comfort!')
		return false
	end
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
  local generated_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
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
    gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
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