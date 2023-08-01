require 'lib.moonloader'
local sampev = require('samp.events')
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local cfg = inicfg.load(
{
    week        =   {   box = 0,   az = 0,    money = 0,    larec = 0  },
    today       =   {   box = 0,   az = 0,    money = 0,    larec = 0  },
    alltime     =   {   box = 0,   az = 0,    money = 0,    larec = 0  },
    main        =   {   hasreturned =   0,              yesterday = '' }
}, 
"kbstats")
local day = {
    [0] = 'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота'
}
print(day[tonumber(os.date('%w'))])

local kbstats = imgui.ImBool(false)
if not doesFileExist('moonloader/config/kbstats.ini') then inicfg.save(cfg, 'kbstats') end
function main()
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage("[KBSTATS] {ffffff}Скрипт успешно запущен, команда '/kbstats'! Создатель скрипта: {3b3b7d}Leonid Romanov", 0x3b3b7d)
    sampRegisterChatCommand('kbstats', function()
        kbstats.v = not kbstats.v
        imgui.Process = kbstats.v
    end)
    print(yesterday)
    while true do
        wait(0)
        if tonumber(os.date('%w')) == 1 and tonumber(cfg.main.hasreturned) == 0 then
            cfg.main.hasreturned = 1 
            cfg.week.box = 0 
            cfg.week.az = 0 
            cfg.week.money = 0 
            cfg.week.larec = 0
            inicfg.save(cfg, 'kbstats.ini')
        end
        if tonumber(os.date('%w')) ~= 1 and tonumber(cfg.main.hasreturned) == 1 then
            cfg.main.hasreturned = 0
            print('dfkgldlkdflsdfl')
            inicfg.save(cfg, 'kbstats.ini')
        end
        if cfg.main.yesterday ~= day[tonumber(os.date('%w'))] then 
            cfg.main.yesterday = day[tonumber(os.date('%w'))]
            cfg.today.box = 0 cfg.today.az = 0 cfg.today.money = 0 cfg.today.larec = 0
            inicfg.save(cfg, 'kbstats.ini')
        end
    end
end
local vh, sh = getScreenResolution()
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.OnDrawFrame()
    if kbstats.v then
        imgui.ShowCursor = false
                    
        imgui.SetNextWindowPos(imgui.ImVec2(vh / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(-1.2, -1.7))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 195), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('', kbstats.v, imgui.WindowFlags.NoTitleBar +imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize)
        imgui.PushFont(fontsize)
            imgui.CenterText(u8'Статистика КБ')
        imgui.PopFont()
        imgui.Columns(2)
        imgui.Separator()
        imgui.Text(u8'Ящиков за сегодня: '..cfg.today.box)
        imgui.Text(u8'Ящиков за неделю: '..cfg.week.box)
        imgui.Text(u8'Ящиков за всё время: '..cfg.alltime.box)

        imgui.NextColumn()
        imgui.Text(u8'Ларцов за сегодня: '..cfg.today.larec)
        imgui.Text(u8'Ларцов за неделю: '..cfg.week.larec)
        imgui.Text(u8'Ларцов за всё время: '..cfg.alltime.larec)
        imgui.Separator()
        imgui.NextColumn()
        imgui.Text(u8'AZ за сегодня: '..cfg.today.az)
        imgui.Text(u8'AZ за неделю: '..cfg.week.az)
        imgui.Text(u8'AZ за всё время: '..cfg.alltime.az)

        imgui.NextColumn()
        imgui.Text(u8'Денег за сегодня: '..cfg.today.money)
        imgui.Text(u8'Денег за неделю: '..cfg.week.money)
        imgui.Text(u8'Денег за всё время: '..cfg.alltime.money)
        imgui.Separator()
        imgui.End()
    end
end

function sampev.onServerMessage(color, text)
    if text:find('Вы взяли ящик с драгоценностями') then 
        cfg.week.box = cfg.week.box + 1
        inicfg.save(cfg, 'kbstats.ini')
        cfg.today.box = cfg.today.box + 1
        inicfg.save(cfg, 'kbstats.ini')
        cfg.alltime.box = cfg.alltime.box + 1
        inicfg.save(cfg, 'kbstats.ini')
    end
    if text:find('За ящиком лежало еще кое') then 
        cfg.week.larec = cfg.week.larec + 1
        inicfg.save(cfg, 'kbstats.ini')
        cfg.today.larec = cfg.today.larec + 1
        inicfg.save(cfg, 'kbstats.ini')
        cfg.alltime.larec = cfg.alltime.larec + 1
        inicfg.save(cfg, 'kbstats.ini')
    end
    if text:find('%[Подсказка%] .*$') then
        if text:find('получили (.*)$') then
            money = text:match('получили (.*)$')
            d1 = money:match('(%d*) %d*')
            d2 = money:match('%d* (%d*)')
            money = d1..''..d2
            money = tonumber(money)
            cfg.week.money = cfg.week.money + money
            inicfg.save(cfg, 'kbstats.ini')
            cfg.today.money = cfg.today.money + money
            inicfg.save(cfg, 'kbstats.ini')
            cfg.alltime.money = cfg.alltime.money + money
            inicfg.save(cfg, 'kbstats.ini')
        end
    end
    if text:find('%[Подсказка%] .* AZ Coins') then
        
        az = text:match('(%d*) AZ')
        cfg.week.az = cfg.week.az + az
        inicfg.save(cfg, 'kbstats.ini')
        cfg.today.az = cfg.today.az + az
        inicfg.save(cfg, 'kbstats.ini')
        cfg.alltime.az = cfg.alltime.az + az
        inicfg.save(cfg, 'kbstats.ini')
    end
end


function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowRounding = 5.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0

    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.90)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()