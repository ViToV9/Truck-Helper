script_name("Truck Helper")
script_author(" KJ // Likuur")
script_version("2.2")
----------------- [Библиотеки] ---------------------------
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
local sizeX, sizeY = getScreenResolution()
local monet = require 'MoonMonet'
local http = require("socket.http")
local ltn12 = require("ltn12")
local lfs = require("lfs")

local tab = 0
local OilMenu = new.bool(false)
local WinState = new.bool(false)
local WinState2 = new.bool(false)
local found_update = imgui.new.bool()
local weight = 'не пройдено'
local direct = 'Неизвестно'

local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/Truck Helper"
local path_settings = configDirectory .. "/settings.json"
local path_helper = getWorkingDirectory():gsub('\\','/') .. "/Truck Helper.lua"
local settings = {}
local default_settings = {
    cfg ={
        time = 0,
        vremena = true,
        innavigator = true,
        salarybox = true,
        skipdialogi = true,
        invzvesh = true,
        zarplata = true,
        larci = true,
        reisi = true,
        realtime = true,
        custom_dpi = 1.0,
        autofind_dpi = false,
    },
    stats = {
 boxing = 0,
 boxingsalary = 0,
 zarplatas = 0,
 reys = 0,
    },
    	theme = {
        moonmonet = (61951)
    },
    knopa = {
        pochinka = true,   
        fillcar = true,   
        dveri = true,   
        key = true,
        rejim = true,
		domk  = true,
    }
}
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path_settings) then
        settings = default_settings
		print('Файл с настройками не найден, использую стандартные настройки!')
    else
        local file = io.open(path_settings, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print(' Не удалось открыть файл с настройками, использую стандартные настройки!')
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
					print('Настройки успешно загружены!')
				else
					print('Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('Не удалось открыть файл с настройками, использую стандартные настройки!')
        end
    end
end
function save()
    local file, errstr = io.open(path_settings, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print(' Настройки сохранены!')
        return result
    else
        print('Не удалось сохранить настройки хелпера, ошибка: ', errstr)
        return false
    end
end
load_settings()
--------------------------------------------------------------------
local pochinka = imgui.new.bool(settings.knopa.pochinka or false)	
local realtime = imgui.new.bool(settings.cfg.realtime or false)	
local fillcar = imgui.new.bool(settings.knopa.fillcar or false)
local dveri = imgui.new.bool(settings.knopa.dveri or false)	
local key = imgui.new.bool(settings.knopa.key or false)
local rejim = imgui.new.bool(settings.knopa.rejim or false)
local domk = imgui.new.bool(settings.knopa.domk or false)
local skipdialogi = imgui.new.bool(settings.cfg.skipdialogi or false)
local vremena = imgui.new.bool(settings.cfg.vremena or false)
local invzvesh = imgui.new.bool(settings.cfg.invzvesh or false)
local innavigator = imgui.new.bool(settings.cfg.innavigator or false)
local zarplata = imgui.new.bool(settings.cfg.zarplata or false)
local larci = imgui.new.bool(settings.cfg.larci or false)
local reisi = imgui.new.bool(settings.cfg.reisi or false)
local infobarik = imgui.new.bool(false)
local timeStatus = false
time = new.int(settings.cfg.time)

function check_update()
	
	print('Начинаю проверку на наличие обновлений...')
	msg('Начинаю проверку на наличие обновлений...')
	local path = configDirectory .. "/Update_Info.json"
	os.remove(path)
	local url = 'https://github.com/ViToV9/Truck-Helper/raw/refs/heads/main/Update_Info.json'
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "finished" then
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("Текущая установленная версия:", thisScript().version)
					print("Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('Доступно обновление!')
						msg('Доступно обновление!')
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						found_update[0] = true
					else
						print('Обновление не нужно!')
						msg('Обновление не нужно, у вас актуальная версия!')
					end
				end
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("Текущая установленная версия:", thisScript().version)
					print("Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('Доступно обновление!')
						msg('Доступно обновление!')
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						found_update[0] = true
					else
						print('Обновление не нужно!')
						msg('Обновление не нужно, у вас актуальная версия!')
					end
				end
			end
		end)
	end
	function readJsonFile(filePath)
		if not doesFileExist(filePath) then
			print("Ошибка: Файл " .. filePath .. " не существует")
			return nil
		end
		local file = io.open(filePath, "r")
		local content = file:read("*a")
		file:close()
		local jsonData = decodeJson(content)
		if not jsonData then
			print("Ошибка: Неверный формат JSON в файле " .. filePath)
			return nil
		end
		return jsonData
	end
end
function downloadToFile(url, path, callback, progressInterval)
	callback = callback or function() end
	progressInterval = progressInterval or 0.1

	local effil = require("effil")
	local progressChannel = effil.channel(0)

	local runner = effil.thread(function(url, path)
	local http = require("socket.http")
	local ltn = require("ltn12")

	local r, c, h = http.request({
		method = "HEAD",
		url = url,
	})

	if c ~= 200 then
		return false, c
	end
	local total_size = h["content-length"]

	local f = io.open(path, "wb")
	if not f then
		return false, "failed to open file"
	end
	local success, res, status_code = pcall(http.request, {
		method = "GET",
		url = url,
		sink = function(chunk, err)
		local clock = os.clock()
		if chunk and not lastProgress or (clock - lastProgress) >= progressInterval then
			progressChannel:push("downloading", f:seek("end"), total_size)
			lastProgress = os.clock()
		elseif err then
			progressChannel:push("error", err)
		end

		return ltn.sink.file(f)(chunk, err)
		end,
	})

	if not success then
		return false, res
	end

	if not res then
		return false, status_code
	end

	return true, total_size
	end)
	local thread = runner(url, path)

	local function checkStatus()
	local tstatus = thread:status()
	if tstatus == "failed" or tstatus == "completed" then
		local result, value = thread:get()

		if result then
		callback("finished", value)
		else
		callback("error", value)
		end

		return true
	end
	end

	lua_thread.create(function()
	if checkStatus() then
		return
	end

	while thread:status() == "running" do
		if progressChannel:size() > 0 then
		local type, pos, total_size = progressChannel:pop()
		callback(type, pos, total_size)
		end
		wait(0)
	end

	checkStatus()
	end)
end
function downloadFileFromUrlToPath(url, path)
	print('Начинаю скачивание файла в ' .. path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "downloading" then
				--print(("Скачивание %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				if download_helper then
					msg('Загрузка новой версии хелпера завершена успешно! Перезагрузка..')
					reload_script = true	
					script_reload()			
					end
			end
		end)
	end
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
    
    imgui.Begin('##2Window', WinState2, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoBackground) 
    
        if settings.knopa.pochinka then
            if imgui.Button(fa.CAR_WRENCH .. u8' Починть') then 
                sampSendChat('/repcar')
            end
        end
        
        if settings.knopa.fillcar then
            if imgui.Button(fa.GAS_PUMP .. u8' Заправить') then 
                sampSendChat('/fillcar')
            end
        end

        if settings.knopa.key then
            if imgui.Button(fa.KEY .. u8' Ключи') then 
                sampSendChat('/key')
            end
        end
       
        if settings.knopa.dveri then
            if imgui.Button(fa.DOOR_OPEN .. u8' Двери') then 
                sampSendChat('/lock')
            end
        end
         
         if settings.knopa.rejim then
            if imgui.Button(u8' Режим') then 
                sampSendChat('/style')
            end
        end
        
         if settings .knopa.domk then
            if imgui.Button(fa.BLINDS_RAISED .. u8' Домкрат') then 
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
        
        if settings.cfg.realtime then
  imgui.Text(fa.CLOCK .. u8(' Текущее время: ') .. u8(get_time()))  
  end
        
        if settings.cfg.zarplata then
            imgui.Text(fa.CIRCLE_DOLLAR .. u8'  Зарплата: ' ..separator(settings.stats.zarplatas).. '$')
        end 
        
        if settings.cfg.larci then
            imgui.Text(fa.BOX .. u8' Ларцов: ' ..settings.stats.boxing.. 'шт') 
        end
                   
        if settings.cfg.reisi then
            imgui.Text(fa.ROAD .. u8' Рейсов: ' ..settings.stats.reys) 
        end
        
        if settings.cfg.innavigator then
        imgui.Text(fa.ROAD .. u8' Навигатор: '..u8(direct))
        end
        
        if settings.cfg.invzvesh then
        imgui.Text(fa.TRUCK_RAMP_BOX .. u8' Взвешивание: '..u8(weight))
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
        settings.stats.boxing = settings.stats.boxing + 1      
        save()
    end
    if text:find('Ваша зарплата за рейс: $(%d+)') then	    
        local salary = text:match('Ваша зарплата за рейс: $(%d+)')
        settings.stats.zarplatas = settings .stats.zarplatas + salary
        settings.stats.reys = settings.stats.reys + 1
        weight = 'не пройдено'
        save()
    end
    if text:find('Благодаря улучшениям вашей семьи вы получаете дополнительную зарплату: $(%d+).') then	    
        local famzp = text:match('Благодаря улучшениям вашей семьи вы получаете дополнительную зарплату: $(%d+).')
        settings.stats.zarplatas = settings.stats.zarplatas + famzp
        save()
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
msg("Загрузка хелпера прошла успешно!")
show_arz_notify('info', 'Truck Helper', "Загрузка хелпера прошла успешно!", 3000)
print(' Загрузка хелпера прошла успешно!')
msg("Чтоб открыть меню хелпера введите команду {009EFF}/db")
check_update()
sampRegisterChatCommand('db', function() OilMenu[0] = not OilMenu[0] end)
end


imgui.OnFrame(function() return OilMenu[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600 * MONET_DPI_SCALE, 375	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
    imgui.Begin(fa.TRUCK .. ' Truck Helper', OilMenu, imgui.WindowFlags.NoCollapse)
    if imgui.BeginTabBar('Tabs') then			  
        if imgui.BeginTabItem(fa.GEAR .. u8' Настройки инфобара') then
        imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 310 * MONET_DPI_SCALE), true)		
            
                if imgui.Checkbox(u8'Отображение информации',infobarik) then
                    WinState[0]= not WinState[0]              
                end
                if imgui.Checkbox(u8'Отображение секундомера',vremena) then
                    settings.cfg.vremena = vremena[0]
                    save() 
                end
    
         if imgui.Checkbox(u8'Отображение времени',realtime) then
                    settings.cfg.realtime = realtime[0]
                    save() 
                end
    
                if imgui.Checkbox(u8'Отображение зарплаты',zarplata) then
                    settings.cfg.zarplata = zarplata[0]
                    save() 
                end                                          
                if imgui.Checkbox(u8'Отображение ларцов',larci) then 
                    settings.cfg.larci = larci[0]
                    save() 
                end                                                                                            				
                if imgui.Checkbox(u8'Отображение рейсов',reisi) then 
                    settings.cfg.reisi = reisi[0]
                    save() 
                end     
                if imgui.Checkbox(u8'Отображение навигатора',innavigator) then 
                    settings.cfg.innavigator = innavigator[0]
                    save() 
                end   
                 if imgui.Checkbox(u8'Отображение взвешивания',invzvesh) then 
                    settings.cfg.invzvesh = invzvesh[0]
                    save() 
                end   
                imgui.Separator()
                if imgui.Checkbox(fa.FORWARD .. u8' Скип лишних диалогов',skipdialogi) then         
          settings.knopa.skipdialogi = skipdialogi[0]      msg('Теперь у вас' .. (skipdialogi[0] and ' автоматически будут скипаться лишние диалоги.' or ' не будут автоматически скипаться лишние диалоги.'))        
                    save() 
                end                      
                imgui.Separator()
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
               imgui.EndChild()		     
            imgui.EndTabItem()
        end
               
        if imgui.BeginTabItem(fa.GEAR .. u8' Настройки хелпбара') then
        imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 209 * MONET_DPI_SCALE), true)
            
                if imgui.Checkbox(u8'Отображение кнопок',infobarik2) then
                    WinState2[0]= not WinState2[0]              
                end     
                if imgui.Checkbox(u8'Отображение кнопки [ Починка ] ',pochinka) then
                    settings.knopa.pochinka = pochinka[0]
                    save() 
                end 
                
                if imgui.Checkbox(u8'Отображение кнопки [ Заправка ] ',fillcar) then
                    settings.knopa.fillcar = fillcar[0]
                    save() 
                end 
                
                if imgui.Checkbox(u8'Отображение кнопки [ Ключи ] ',key) then
                    settings.knopa.key = key[0]
                    save() 
               end
                    
                if imgui.Checkbox(u8'Отображение кнопки [ Двери ] ',dveri) then
                    settings.knopa.dveri = dveri[0]
                    save()
               end
               
                if imgui.Checkbox(u8'Отображение кнопки [ Режим ] ',rejim) then
                    settings.knopa.rejim = rejim[0]
                    save() 
                end
                
                if imgui.Checkbox(u8'Отображение кнопки [ Домкрат ] ',domk) then
                    settings.knopa.domk = domk[0]
                    save() 
                end
                                                
        imgui.EndChild()		
        imgui.EndTabItem()
    end 
   
    
    if imgui.BeginTabItem(fa.INFO .. u8' Информация') then
    
imgui.BeginChild('##1', imgui.ImVec2(589 * MONET_DPI_SCALE, 121 * MONET_DPI_SCALE), true)
    imgui.CenterText(fa.CIRCLE_INFO .. u8' Дополнительная информация про хелпер')
    imgui.Separator()
    
    imgui.Text(fa.CIRCLE_USER..u8" Разработчик данного хелпера: KJ // Likuur")
				imgui.Separator()
				imgui.Text(fa.CIRCLE_INFO..u8' Установленная версия хелпера ' .. thisScript().version)				
				
				imgui.Separator()
				imgui.Text(fa.HEADSET..u8" Тех.поддержка по хелперу:")
				imgui.SameLine()
				if imgui.SmallButton('Telegram') then
					openLink('https://t.me/Jake_S2')
				end
				
				imgui.Separator()
				imgui.Text(fa.GLOBE..u8" Тема хелпера на форуме BlastHack:")
				imgui.SameLine()
				if imgui.SmallButton(u8'https://www.blast.hk/threads/217684/') then
					openLink('https://www.blast.hk/threads/217684/')							
end
				imgui.EndChild()					
 imgui.BeginChild('##3', imgui.ImVec2(589 * MONET_DPI_SCALE, 87 * MONET_DPI_SCALE), true)
				imgui.CenterText(fa.PALETTE .. u8' Цветовая тема хелпера:')
				imgui.Separator()
				if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
                r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
              argb = join_argb(0, r, g, b)
                settings.theme.moonmonet = argb
                save()
          apply_n_t()
            end
            imgui.SameLine()
            imgui.Text(fa.NOTE_STICKY..u8' Цвет MoonMonet') 
                   
					imgui.EndChild()
					imgui.BeginChild("##4",imgui.ImVec2(589 * MONET_DPI_SCALE, 42 * MONET_DPI_SCALE),true)
				if imgui.Button(fa.ROTATE_RIGHT .. u8" Перезагрузка ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * settings.cfg.custom_dpi)) then
					reload_script = true
					thisScript():reload()
				end
	imgui.SameLine()
	if imgui.Button(fa.POWER_OFF .. u8" Выключение ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * settings.cfg.custom_dpi)) then
					imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off')
				end
				if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##off', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar ) then
					if not isMonetLoader() then imgui.SetWindowFontScale(settings.cfg.custom_dpi) end
					imgui.CenterText(u8'Вы действительно хотите выгрузить (отключить) хелпер?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.POWER_OFF .. u8' Да, выгрузить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						reload_script = true
						play_error_sound()
						msg('Хелпер приостановил свою работу до следущего входа в игру!')					
						thisScript():unload()
					end
					imgui.End()
				end            					        
imgui.SameLine()
				if imgui.Button(fa.TRASH_CAN .. u8" Удаление ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * settings.cfg.custom_dpi)) then
					imgui.OpenPopup(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete')
				end
				if imgui.BeginPopupModal(fa.TRIANGLE_EXCLAMATION .. u8' Предупреждение ##delete', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
					if not isMonetLoader() then imgui.SetWindowFontScale(settings.cfg.custom_dpi) end
					imgui.CenterText(u8'Вы действительно хотите удалить Truck Helper?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.TRASH_CAN .. u8' Да, я хочу удалить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						msg('Хелпер полностю удалён из вашего устройства!')			
						reload_script = true
						os.remove(path_helper)
						os.remove(path_settings)							os.remove(configDirectory) 							
						thisScript():unload()
					end
					imgui.End()
				end
				imgui.EndChild()            
        imgui.EndTabItem()
        end
        imgui.EndTabBar()
    end
    imgui.End() 
end)  


function deleteAll()
    --и тут всё что нужно
    settings.stats.reys = 0
    settings.stats.boxing = 0
    settings.stats.zarplatas = 0
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
        if #arg == 0 or not arg:find('%d+') then return sampAddChatMessage('[Калькулятор]: {DE9F00}Ошибка, введите /calc [пример]', 0x08A351) end
        sampAddChatMessage('[Truck Helper]: {009EFF}'..arg..' = '..assert(load("return " .. arg))(), 0x08A351)
    end)

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end

get_time = function ()
		return os.date("%H:%M:%S")
	end
	

function script_reload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "Перезагрузка....!", 500)
wait(0)
thisScript():reload()
end)
end

function script_unload()
lua_thread.create(function()
show_arz_notify('info', 'Truck Helper', "Выключение....!", 500)
wait(0)
thisScript():unload()
end)
end

function play_error_sound()
	if not isMonetLoader() and sampIsLocalPlayerSpawned() then
		addOneOffSound(getCharCoordinates(PLAYER_PED), 1149)
	end
end

function msg(text)
    gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
    local a, r, g, b = explode_argb(gen_color.accent1.color_300)
    curcolor = '{' .. rgb2hex(r, g, b) .. '}'
    curcolor1 = '0x' .. ('%X'):format(gen_color.accent1.color_300)
    sampAddChatMessage("[Truck Helper]: {FFFFFF}" .. text, curcolor1)
end

function sampev.onShowTextDraw(id, data)
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		msg('{ffffff}Активирован режим езды Sport!')
		return false
	end
	if data.text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		msg('{ffffff}Активирован режим езды Comfort!')
		return false
	end
end
function sampev.onDisplayGameText(style,time,text)
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~r~Sport!') then
		msg('{ffffff}Активирован режим езды Sport!')
		return false
	end
	if text:find('~n~~n~~n~~n~~n~~n~~n~~n~~w~Style: ~g~Comfort!') then
		msg('{ffffff}Активирован режим езды Comfort!')
		return false
	end
end
--Автообновление взял у MTG MODS автор разрешил https://t.me/mtgmods
imgui.OnFrame(function() return found_update[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.CIRCLE_INFO .. u8" Оповещение##found_update", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
    imgui.CenterText(u8'У вас сейчас установлена версия хелпера ' .. u8(tostring(thisScript().version)) .. ".")
		imgui.CenterText(u8'В базе данных найдена версия хелпера - ' .. u8(updateVer) .. ".")
		imgui.CenterText(u8'Рекомендуется обновиться, дабы иметь весь актуальный функционал!')
		imgui.Separator()
		imgui.CenterText(u8('Что нового в версии ') .. u8(updateVer) .. ':')
		imgui.Text(u8(updateInfoText))
		imgui.Separator()
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Не обновлять ',  imgui.ImVec2(300 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
			found_update[0] = false
		end
		imgui.SameLine()
		if imgui.Button(fa.DOWNLOAD ..u8' Загрузить новую версию',  imgui.ImVec2(300 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
			download_helper = true
			downloadFileFromUrlToPath(updateUrl, path_helper)
			found_update[0] = false
		end
		imgui.End()
    end
)

function isMonetLoader() return MONET_VERSION ~= nil end
if isMonetLoader() then
gta = ffi.load('GTASA') 
ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

function openLink(link)
    gta._Z12AND_OpenLinkPKc(link)
	end


if not settings.cfg.autofind_dpi then
	print('[Truck Helper] Применение авто-размера менюшек...')
	if isMonetLoader() then
		settings.cfg.custom_dpi = MONET_DPI_SCALE
	else
		local base_width = 1366
		local base_height = 768
		local current_width, current_height = getScreenResolution()
		local width_scale = current_width / base_width
		local height_scale = current_height / base_height
		settings.cfg.custom_dpi = (width_scale + height_scale) / 2
	end
	settings.cfg.autofind_dpi = true
	print('[Truck Helper] Установлено значение: ' .. settings.cfg.custom_dpi)
	save()
end


function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterButton(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() 
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count)
end

function apply_monet()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * settings.cfg.custom_dpi, 5 * settings.cfg.custom_dpi)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * settings.cfg.custom_dpi, 5 * settings.cfg.custom_dpi)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * settings.cfg.custom_dpi, 5 * settings.cfg.custom_dpi)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * settings.cfg.custom_dpi, 2 * settings.cfg.custom_dpi)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * settings.cfg.custom_dpi
    imgui.GetStyle().GrabMinSize = 10 * settings.cfg.custom_dpi
    imgui.GetStyle().WindowBorderSize = 1 * settings.cfg.custom_dpi
    imgui.GetStyle().ChildBorderSize = 1 * settings.cfg.custom_dpi
    imgui.GetStyle().PopupBorderSize = 1 * settings.cfg.custom_dpi
    imgui.GetStyle().FrameBorderSize = 1 * settings.cfg.custom_dpi
    imgui.GetStyle().TabBorderSize = 1 * settings.cfg.custom_dpi
	imgui.GetStyle().WindowRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().ChildRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().FrameRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().PopupRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().ScrollbarRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().GrabRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().TabRounding = 8 * settings.cfg.custom_dpi
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
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
end
function onScriptTerminate(script, game_quit)
    if script == thisScript() and not game_quit and not reload_script then
		msg('Произошла неизвестная ошибка, хелпер приостановил свою работу!')
		end
	end