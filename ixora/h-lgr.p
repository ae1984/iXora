/* h-lgr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        11.02.2008 id00004 увеличил фрейм
        06.02.2012 dmitriy - разбивка по юр и физ счетам, а так же ОД и все остальные (ТЗ 1076)
        16.10.2012 dmitriy - добавил в list1 группу счетов 138,139,140
        25.12.2012 Lyubov - ТЗ № 1161, исключила счета KassaNova
        13.05.2013 evseev - tz-1828
        23.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

/* h-lgr.p
*/
{global.i}

def output parameter p-znak as char.
def shared var p-typ like cif.type.
def shared var p-dep as char.
def var list1 as char init "138,139,140,202,204,208,222,246,249,A38,A39,A40". /*247,248,466,467,468,469,470,471,472,473,474,475,476,477".*/
def var list2 as char init "151,152,153,154,157,158,171,172,173,174,175,176,177,178,179,396,397,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20". /*160,161,453,455,456,457,458,459,460,461,462,463,464,465,491,492,493,494,495,496,497,498,499,*/

def var list3 as char.

if p-typ <> "" and p-dep <> "" then do:
    if p-typ = "P" and p-dep = "L" then list3 = list1.
    if p-typ = "B" and p-dep = "L" then list3 = list2.

    if p-dep <> "L" then do:
        for each lgr where substr(trim(lgr.des),1,3) ne 'n/a' and lookup(lgr.lgr,list1) eq 0 and lookup(lgr.lgr,list2) eq 0 no-lock:
            if list3 = "" then list3 = lgr.lgr.
            else list3 = list3 + "," + lgr.lgr.
        end.
    end.
end.
else do:
    for each lgr where substr(trim(lgr.des),1,3) ne 'n/a' and (lookup(lgr.lgr,list1) eq 0 or lookup(lgr.lgr,list2) eq 0) no-lock:
        if list3 = "" then list3 = lgr.lgr.
        else list3 = list3 + "," + lgr.lgr.
    end.
end.

        {itemlist.i
           &var  = " "
           &updvar  = " "
           &where = "substr(trim(lgr.des),1,3) ne 'n/a' and lookup(lgr.lgr,list3) ne 0"
           &frame = "row 5 centered scroll 1 12 down overlay "
           &index = "lgr"
           &chkey = "lgr"
           &chtype = "string"
           &file = "lgr"
           &flddisp = "lgr.lgr lgr.led lgr.des format 'x(30)' lgr.gl lgr.nxt"
           &funadd = " p-znak = lgr.lgr.
                 if frame-value = "" "" then do:
                 {imesg.i 9205}.
                pause 1.
                next.
              end." }
