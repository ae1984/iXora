/* swmtswin.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Заполнение временной таблицы для ввода свифтового макета
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
        15/10/03 sasco для 50 поля по-умолчанию берется тип "K"
        09.12.2003 sasco дабавил обработку Атырау
        02/07/2007 madiyar - немного переделал, чтобы убрать явное упоминание кодов конкретных филиалов
        10.05.2010 k.gitalov - переделал заполнение 50 поля
        21.02.2011 aigul - переделала заполнение 56, 57, 59 полей
        20.07.2011 Luiza для swbody.swfield = '50' and swmt = '103' and swbody.type <> '' then tmpf = 'A,K,F' добавила тип "F"
        07.11.2011 aigul - добавила форму собственности парнера в 59 поле
        08.11.2011 aigul - вывод данных для МТ103, вывод 56-поля
        31.01.2012 aigul - заполнение МТ 103 для ИБ
        31.01.2012 aigul - исправила вывод 56-поля
        16.02.2012 aigul - исправила вывод 70-поля
        27.09.2012 evseev - логирование
        02.09.2013 evseev - tz-926
*/
def var tmpRNN as char.
def var tmpstr3 as char.
def var v-engcity as char.
def var tmpi as integer.
def var tmpf as char.
def var ruseng as char.
def var f71  as integer init 0. /* Признак заполнения 71 поля, в 103 макете их может быть несколько */
def buffer tmpswb for swbody.
def var v-partner  as char.

def var v-addr as char.
def var v-addr1 as char.
def var v-num as int.
def var v-rnn as char.
def var v-tmp as char.
def var v-s1 as char.
def var v571 as char.
def var v572 as char.
def var v-detch as char.
def var v-bank as char.
def var v-56chk as char.
def var v-56chk1 as char.
def var v-56chk2 as char.
def var v-56chk3 as char.
def var v-56chk4 as char.
def var v-56chk5 as char.
def var v-num56 as int.
def var k as int.
def var v-city as char.
def var v-nm as char.
def var v-inn as char.
def var v-ib as logical initial no.
def var v-ib1 as logical initial no.
def var v-str1 as char.
def var v-str2 as char.

def var v-knp as char.
def var v-add as char.
f71 = 0.

def var p-acc as char.
def var p-name as char.
def var p-rnn as char.
def var p-addr as char.
def var p-addr1 as char.
def var v-int as logical initial yes.

/*def var  v-isfind as logical no-undo.*/
def var  v-source as char no-undo.
/*def var  v-rmz as char no-undo.
v-rmz = "".*/
run savelog("swiftmaket", "swmtswin.i 78. " + s-remtrz + " " + string(swlist.flist) ).
/*find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.*/
if avail remtrz then v-source = remtrz.source.

if v-source <> "IBH" and swmt = "103" then do:
/*    if avail remtrz then do:
       v-rmz = substr(remtrz.SQN,index(remtrz.SQN,"RMZ"),10).
       run findrmz(v-rmz, output v-isfind, output v-source ).
    end.*/
    if index(remtrz.sqn, "IBH") > 0 then  v-source = "IBH".
end.
run savelog("swiftmaket", "swmtswin.i 94. " + s-remtrz + " " + /*v-rmz +*/ " " + v-source ).

if avail remtrz and swmt = "103" and v-source = "IBH" then do:
   for each swbody where swbody.rmz = s-remtrz no-lock:
      if swbody.swfield = 'DS' then do:
           create swin.
           Assign
               swin.type    = swbody.type
               swin.rmz     = s-remtrz
               swin.swfield = swbody.swfield
               swin.content[1] = destination
               swin.content[2] = substr(destdescr,1,35)
               swin.content[3] = substr(destdescr,36,35)
               swin.content[4] = substr(destdescr,71,35) no-error.
      end. else if swbody.swfield = '56' and swbody.type = 'A' then do:
          create swin.
          assign
            swin.content[2] = swbody.content[1]
            swin.type       = swbody.type
            swin.swfield    = swbody.swfield
            swin.rmz     = s-remtrz.
            find first swibic where swibic.bic = trim(swbody.content[1]) no-lock no-error.
            if avail swibic then swin.content[3] = swibic.name.
      end. else if swbody.swfield = '57' and swbody.type = 'A' then do:
          create swin.
          assign
            swin.content[2] = swbody.content[1]
            swin.type       = swbody.type
            swin.swfield    = swbody.swfield
            swin.rmz     = s-remtrz.
            find first swibic where swibic.bic = trim(swbody.content[1]) no-lock no-error.
            if avail swibic then swin.content[3] = swibic.name.
      end. else do:
          create swin.
          assign
            swin.content[1] = swbody.content[1]
            swin.content[2] = swbody.content[2]
            swin.content[3] = swbody.content[3]
            swin.content[4] = swbody.content[4]
            swin.content[5] = swbody.content[5]
            swin.content[6] = swbody.content[6]
            swin.type       = swbody.type
            swin.swfield    = swbody.swfield
            swin.rmz        = s-remtrz.
      end.
   end.
end. else do:
    repeat i = 1 to NUM-ENTRIES(swlist.flist):
        /* Найдем поле и его характеристики */
        find first swfield where swfield.swfld = ENTRY (i,swlist.flist) no-lock.
        /* Установим признаки обязательного или необязательного поля */
        if LOOKUP(ENTRY (i, swlist.flist), swlist.mandatory) > 0 then tmps = 'M'. else tmps = 'O'.
        tmpf = swfield.feature.
        find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
        if avail remtrz and remtrz.source = "IBH" then v-ib = yes.
        if avail remtrz and substr(remtrz.ref,7,2) = "IB" then v-ib1 = yes.
        create swin.
        if ENTRY (i, swlist.flist) = '71' and swmt = '103' and f71 = 0 then
           find first swbody where swbody.rmz=s-remtrz and swbody.swfield=ENTRY (i, swlist.flist) and swbody.type = 'A' no-lock no-error.
        else if ENTRY (i, swlist.flist) = '71' and swmt = '103' and f71 = 1 then
           find first swbody where swbody.rmz=s-remtrz and swbody.swfield=ENTRY (i, swlist.flist) and swbody.type = 'F' no-lock no-error.
        else
           find first swbody where swbody.rmz=s-remtrz and swbody.swfield=ENTRY (i, swlist.flist) no-lock no-error.
        /* Если форма уже набрана загрузим данные */
        if avail swbody and v-ib = no then do:
            find first remtrz where remtrz.remtrz = swbody.rmz no-lock no-error.
            if avail remtrz and (remtrz.intmed = ? or remtrz.intmed = "") then v-int = no.
            /* для рублевых платежей - подстановка WAS IST /DAS/ */
            if crc.crc = 4 and swbody.swfield = '72' then do:
                /* Уже есть /DAS/ */
                if substr (swbody.content[1], 1, 5) = '/DAS/' then
                     assign
                        swin.content[1] = swbody.content[1]
                        swin.content[2] = swbody.content[2]
                        swin.content[3] = swbody.content[3]
                        swin.content[4] = swbody.content[4]
                        swin.content[5] = swbody.content[5]
                        swin.content[6] = swbody.content[6]
                        swin.type       = swbody.type
                        swin.swfield    = swbody.swfield.
                else do: /* в старом макете нет /DAS/ - так добавим же его! */
                    assign swin.content[1] = ('/DAS/' + substr(string(year(remtrz.valdt2)), 3, 2) + string(month(remtrz.valdt2),"99") + string(day(remtrz.valdt2), "99")) no-error.
                    assign
                        swin.content[2] = swbody.content[1]
                        swin.content[3] = swbody.content[2]
                        swin.content[4] = swbody.content[3]
                        swin.content[5] = swbody.content[4]
                        swin.content[6] = swbody.content[5]
                        swin.type       = swbody.type
                        swin.swfield    = swbody.swfield.
                end.
           end. else do:
                assign
                    swin.content[1] = swbody.content[1]
                    swin.content[2] = swbody.content[2]
                    swin.content[3] = swbody.content[3]
                    swin.content[4] = swbody.content[4]
                    swin.content[5] = swbody.content[5]
                    swin.content[6] = swbody.content[6]
                    swin.type       = swbody.type
                    swin.swfield    = swbody.swfield.
           end.
           /* Попытаемся прогрузить платеж еще раз если он набирался в РКО и была неизвестна ДатВал2 */
           if swbody.swfield="32" and swbody.content[1]=? then do:
                tmpstr = string(remtrz.payment, ">>>>>>>>>>>>9.99").
                tmpstr = replace(tmpstr, ".", ",").
                swin.content[1] = substr(string(year(remtrz.valdt2)), 3, 2)  + "/" + string(month(remtrz.valdt2),"99") + "/" +
                                  string(day(remtrz.valdt2), "99")  + " " + crc.code + " " + tmpstr no-error.
                find first tmpswb where tmpswb.rmz = swbody.rmz and tmpswb.swfield=swbody.swfield no-error.
                if avail tmpswb then tmpswb.content[1] = swin.content[1].
                release tmpswb.
           end.
           /* обновим DESTINATION*/
           if swbody.swfield='DS' then do:
                Assign
                    swin.content[1] = destination
                    swin.content[2] = substr(destdescr,1,35)
                    swin.content[3] = substr(destdescr,36,35)
                    swin.content[4] = substr(destdescr,71,35) no-error.
           end.
           if swbody.swfield='50' and swmt = '100' then assign swin.feature = '' swin.type = ''.
           if swbody.swfield='50' and swmt = '103' and swbody.type <> '' then tmpf = 'A,K,F'.
           if swbody.swfield='50' and swmt = '103' and swbody.type = '' then assign tmpf = 'A,K,F' swin.type = 'K'.
           if swbody.swfield='71' and swmt = '103' then do:
                f71 = f71 + 1.
                if f71 = 1 then tmps = "M".
                if f71 = 2 then tmps = "O".
           end.
           if swbody.swfield = '50' and swmt = '103' and v-ib1 then do:
                find first remtrz where remtrz.remtrz = swbody.rmz no-lock no-error.
                if avail remtrz then do:
                    swin.content[1] = "/" + remtrz.sacc.
                    if remtrz.fcrc = 4 then do:
                        run rus-eng4ru(INPUT (swbody.content[1]), output p-name).
                        swin.content[2] = p-name.
                        swin.content[3] = swbody.content[2].
                        swin.content[4] = substr(swbody.content[3],1,35).
                        swin.content[5] = substr(swbody.content[3],36,35).
                    end. else do:
                        swin.content[2] = swbody.content[1].
                        swin.content[3] = swbody.content[2].
                        swin.content[4] = substr(swbody.content[3],1,35).
                        swin.content[5] = substr(swbody.content[3],36,35).
                    end.
                end.
           end.
           if swbody.swfield = '56' and swmt = '103' and v-ib1 then do:
                if crc.crc <> 4 then do:
                    find first remtrz where remtrz.remtrz = swbody.rmz no-lock no-error.
                    if avail remtrz then do:
                        if remtrz.intmed = ? or remtrz.intmed = "" then v-56chk = "".
                        else do:
                            v-56chk = entry(1,remtrz.intmed," ").
                            v-num56 = num-entries(remtrz.intmed," ").
                            if v-num56 > 1 then v-56chk2 = entry(2,remtrz.intmed," ").
                            if v-num56 > 2 then do:
                                do k = 3 to v-num56:
                                    if v-56chk3 = " " then v-56chk3 = entry(k,remtrz.intmed," ").
                                    else v-56chk3 = v-56chk3 + " "  + entry(k,remtrz.intmed," ").
                                end.
                            end.
                        end.
                    end.
                    if v-56chk <> "" then do:
                        swin.type = 'A'.
                        swin.content[1] = ' ' .
                        if v-56chk matches "*SWIFT*" then do:
                            swin.content[1] = "".
                            swin.content[2] = v-56chk2.
                            swin.content[3] = substr(v-56chk3,1,35).
                            swin.content[4] = substr(v-56chk3,36,35).
                        end. else do:
                            swin.content[1] = "".
                            swin.content[2] = "".
                            swin.content[3] = substr(remtrz.intmed,1,35).
                            swin.content[4] = substr(remtrz.intmed,36,35).
                        end.
                    end.
                    if (v-int = no and swbody.swfield = '56') then do:
                        swin.type = 'N'.
                        swin.content[1] = "NONE".
                        swin.content[2] = "".
                        swin.content[3] = "".
                        swin.content[4] = "".
                    end.
                end. else do:
                    swin.type = 'N'.
                    swin.content[1] = "NONE".
                    swin.content[2] = "".
                    swin.content[3] = "".
                    swin.content[4] = "".
                end.
           end.
           if swbody.swfield = '57' and swmt = '103' and v-ib1 then do:
                def var v-entr as int.
                def var l as int.
                find first remtrz where remtrz.remtrz = swbody.rmz no-lock no-error.
                if avail remtrz then do:
                    find first swibic where swibic.bic = entry(2,remtrz.bb[1]," ") or swibic.bic matches entry(2,remtrz.bb[1]," ") + "*"
                                            or swibic.bic matches substr(entry(2,remtrz.bb[1]," "),1,8) + "*" no-lock no-error.
                    if avail swibic then do:
                        swin.type = 'A'.
                        v-bank = swibic.name.
                        v571 = entry(2,remtrz.bb[1],"").
                        v-city = swibic.city.
                    end.
                    if not avail swibic then do:
                        find first swibic where swibic.bic = entry(1,remtrz.bb[2]," ") no-lock no-error.
                        if avail swibic then do:
                            swin.type = 'A'.
                            v-bank = swibic.name.
                            v-city = swibic.city.
                            v571 = "SWIFT/ " + remtrz.bb[2].
                        end.
                        if not avail swibic then  swin.type = 'D'.
                    end.
                    if remtrz.fcrc = 4 then do:
                        swin.type = 'D'.
                        find first swibic where swibic.bic = entry(2,remtrz.bb[1]," ") + "." + entry(3,remtrz.bb[1]," ") no-lock no-error.
                        if avail swibic then do:
                            v-bank = swibic.name.
                            v-city = swibic.city.
                            run rus-eng4ru(INPUT (v-bank), output  v-bank).
                            run rus-eng4ru(INPUT (v-city), output  v-city).
                        end.
                    end.
                    assign swin.content[1] = ' '.
                    if remtrz.fcrc <> 4 then do:
                        swin.content[2] = /*substr(v571,8,35)*/ v571.
                        swin.content[3] = substr(v-bank,1,35).
                        swin.content[4] = substr(v-city,1,35).
                    end.
                    if remtrz.fcrc = 4 then do:
                        if remtrz.bb[1] <> "" then do:
                            swin.content[1] = entry(1,remtrz.bb[1]," ") + entry(2,remtrz.bb[1]," ") + "." + entry(3,remtrz.bb[1]," ").
                            if v-bank <> "" then do:
                                swin.content[2] = substr(v-bank,1,35).
                                swin.content[3] = substr(v-bank,36,35).
                                swin.content[4] = v-city.
                                if swin.content[3] = "" then do:
                                    swin.content[3] = "G." + v-city.
                                    swin.content[4] = "".
                                end.
                            end. else do:
                                run rus-eng4ru(INPUT (swbody.content[2]), output  v-bank).
                                swin.content[2] = substr(v-bank,1,35).
                                swin.content[3] = substr(v-bank,36,35).
                                swin.content[4] = substr(v-bank,71,35).
                            end.
                        end.
                    end.
                end.
           end.
           if swbody.swfield = '59' and swmt = '103' and v-ib1 then do:
                v-tmp   = trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3]).
                v-s1 = trim(substring( v-tmp, 001, 80 )).
                run rus103eng(v-s1, output ruseng).
                if substr(remtrz.ba,1,1) = "/" then swin.content[1] = "/" + remtrz.ba. else swin.content[1] = "/" + remtrz.ba.
                swin.content[2] = entry(1,ruseng,"/RNN/").
                swin.content[3] = substr(ruseng,36,35).
                swin.content[4] = substr(ruseng,71,35).
                if remtrz.fcrc = 4 then do:
                    run rus-eng4ru(INPUT (v-s1), output ruseng).
                    if substr(remtrz.ba,1,1) = "/" then swin.content[1] = "/" + remtrz.ba. else swin.content[1] = "/" + remtrz.ba.
                    swin.content[2] = substr(ruseng,1,35).
                    swin.content[3] = substr(ruseng,36,35).
                    swin.content[4] = substr(ruseng,71,35).
                end.
           end.
           if swbody.swfield = '70' and swmt = '103' and v-ib1 then do:
                v-detch = remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4].
                if remtrz.fcrc = 4 then do:
                    run rus-eng4ru(v-detch, output ruseng).
                    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                    if avail sub-cod then do:
                        v-knp = substr(sub-cod.rcode,7,3).
                        if v-knp = "119" then v-add  = "(VO70070)".
                        else if v-knp matches "7*" then v-add = "(VO10030)".
                        else if v-knp matches "8*" then v-add = "(VO20020)". else v-add = "(VO99090)".
                        swin.content[1] = v-add + ruseng.
                        swin.content[2] = substr(ruseng,36,35).
                        swin.content[3] = substr(ruseng,71,35).
                        swin.content[4] = substr(ruseng,106,35).
                    end.
                end. else do:
                    run rus103eng(INPUT (v-detch), output ruseng).
                    swin.content[1] = substr(ruseng,1,35).
                    swin.content[2] = substr(ruseng,36,35).
                    swin.content[3] = substr(ruseng,71,35).
                    swin.content[4] = substr(ruseng,106,35).
                end.
           end.
        end. else do: /* Заполнение полей нового макета */
            assign
            swin.content = ''
            swin.type    = if lookup('N',swfield.feature)>0 then "N" else ENTRY (1, swfield.feature)
            swin.rmz     = s-remtrz
            swin.swfield = ENTRY (i, swlist.flist).
            if swin.type = "N" then swin.content[1] = "NONE".
            CASE ENTRY (i, swlist.flist):
                when 'DS' then do:
                    Assign                                         /* обновим DESTINATION*/
                    swin.content[1]=destination
                    swin.content[2]=substr(destdescr,1,35)
                    swin.content[3]=substr(destdescr,36,35)
                    swin.content[4]=substr(destdescr,71,35) no-error.
                end.
                when '20' then assign swin.content[1] = (if crc.crc = 4 then "+" else "") + s-remtrz + "-S".
                when '21' then assign swin.content[1] = (if crc.crc = 4 then "+" else "") + s-remtrz + "-S".
                when '23' then assign swin.content[1] = "CRED".
                when '32' then do:
                    tmpstr = string(remtrz.payment, ">>>>>>>>>>>>9.99").
                    tmpstr = replace(tmpstr, ".", ",").
                    swin.content[2] = crc.code + " " + tmpstr.
                    swin.content[1] = substr(string(year(remtrz.valdt2)), 3, 2)  + "/" + string(month(remtrz.valdt2),"99") + "/" +
                                      string(day(remtrz.valdt2), "99")  + " " + crc.code + " " + tmpstr.
                end.
                when '50' then do:
                    v-engcity = ''.
                    find first cmp no-lock no-error.
                    if avail cmp then do:
                        find sysc where sysc.sysc = "bnkadr" no-lock no-error.
                        if avail sysc and num-entries(sysc.chval,'|') > 7 then v-engcity = entry(8, sysc.chval, "|").
                    end.
                    if trim(v-engcity) <> '' then tmpstr3 = caps(v-engcity) + ' KAZAKHSTAN'. else tmpstr3 = "KAZAKHSTAN".
                    if swmt = '103' then assign swin.type = 'K' tmpf = 'A,K,F'. else assign swin.type = ''
                    tmpf = ''.
                    ruseng = "".
                    find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif then do:
                            tmpRNN = "RNN" + cif.jss.
                            run rus-eng(INPUT trim(cif.prefix + " " + cif.name), output tmpstr).
                            run rus-eng(INPUT trim(cif.addr[2] + cif.addr[3]), output ruseng).
                        end.
                    end.
                    if swmt = '103' and remtrz.source = "IBH" then do:
                        find first aaa where aaa.aaa = remtrz.sacc  no-lock no-error.
                        if avail aaa then do:
                            find first cif where cif.cif = aaa.cif no-lock no-error.
                            if avail cif then do:
                                v-num = num-entries(cif.addr[1]).
                                v-rnn = cif.jss.
                                if v-num < 7 then do:
                                    v-addr = cif.addr[1].
                                    run rus-eng4ru(INPUT (v-addr), output ruseng).
                                end. else do:
                                    v-addr = entry(4,cif.addr[1],",") + " " + entry(5,cif.addr[1],",") + " " + entry(6,cif.addr[1],",") + " " + entry(7,cif.addr[1],",").
                                    run rus-eng4ru(INPUT (v-addr), output ruseng).
                                end.
                            end.
                        end.
                    end.
                    assign swin.content[1] = "/" + remtrz.sacc
                        swin.content[2] = tmpstr
                        swin.content[3] = tmpRNN
                        swin.content[4] = ruseng
                        swin.content[5] = tmpstr3.
                end.
                when '56' then DO:
                    if remtrz.fcrc <> 4 then do:
                        find first vcdocs where vcdocs.dnnum = substr(remtrz.remtrz,4,6) no-lock no-error.
                        if avail vcdocs then do:
                            find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                            if avail vccontrs then do:
                                assign
                                    swin.content[1] = remtrz.ba
                                    swin.content[2] = substr(bankcsw, 1,35)
                                    swin.content[3] = substr(bankc, 1,35)
                                    swin.content[4] = substr(bankc,36,35).
                                find first swibic where swibic.bic = bankcsw no-lock no-error.
                                if avail swibic then swin.type = 'A'.
                                if not avail swibic then swin.type = 'D'.
                            end.
                        end.
                    end.
                    if swmt = '103' and remtrz.fcrc <> 4 and remtrz.source = "IBH" then do:
                        if remtrz.intmed = ? or remtrz.intmed = "" then v-56chk = "".
                        else do:
                            v-56chk = entry(1,remtrz.intmed," ").
                            v-num56 = num-entries(remtrz.intmed," ").
                            if v-num56 > 1 then v-56chk2 = entry(2,remtrz.intmed," ").
                            if v-num56 > 2 then do:
                                do k = 3 to v-num56:
                                    if v-56chk3 = " " then v-56chk3 = entry(k,remtrz.intmed," ").
                                    else v-56chk3 = v-56chk3 + " "  + entry(k,remtrz.intmed," ").
                                end.
                            end.
                        end.
                        if v-56chk <> "" then do:
                            swin.type = 'A'.
                            swin.content[1] = ' ' .
                            if v-56chk matches "*SWIFT*" then do:
                                swin.content[1] = "".
                                swin.content[2] = v-56chk2.
                                swin.content[3] = substr(v-56chk3,1,35).
                                swin.content[4] = substr(v-56chk3,36,35).
                            end. else do:
                                swin.content[1] = "".
                                swin.content[2] = v-56chk.
                                swin.content[3] = v-56chk2.
                                swin.content[4] = v-56chk3.
                            end.
                        end.
                    end.
                end.
                when '57' then /*assign swin.content[1] = remtrz.ba.*/ DO:
                    find first vcdocs where vcdocs.dnnum = substr(remtrz.remtrz,4,6) no-lock no-error.
                    if avail vcdocs then do:
                        find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                        if avail vccontrs then do:
                            assign swin.content[1] = remtrz.ba
                            swin.content[2] = substr(bankbsw,  1,35)
                            swin.content[3] = substr(bankb, 1,35)
                            swin.content[4] = substr(bankb, 36,35).
                            find first swibic where swibic.bic = bankcsw no-lock no-error.
                            if avail swibic then swin.type = 'A'.
                            if not avail swibic then swin.type = 'D'.
                            if remtrz.fcrc = 4 then do:
                                swin.type = 'D'.
                                swin.content[1] = "//RU" + substr(bankbsw,  1,35).
                                run rus-eng4ru(substr(bankb, 1,35), output v-str1).
                                swin.content[2] = v-str1.
                                run rus-eng4ru(substr(bankb, 36,35), output v-str1).
                                swin.content[3] = v-str1.
                                run rus-eng4ru(substr(bankb, 71,35), output v-str1).
                                swin.content[4] = v-str1.
                                find first swibic where swibic.bic = bankbsw no-lock no-error.
                                if avail swibic then do:
                                    run rus-eng4ru(substr(swibic.city, 1,35), output v-str2).
                                    if swin.content[3] = "" then  swin.content[3] = v-str2.
                                    if swin.content[4] = "" and swin.content[3] <> v-str2 then  swin.content[4] = v-str2.
                                    if swin.content[3] <> "" and swin.content[4] <> "" then  swin.content[5] = v-str2.
                                end.
                            end.
                        end.
                    end.
                    if swmt = '103' and remtrz.source = "IBH" then do:
                        find first swibic where swibic.bic = entry(2,remtrz.bb[1]," ") no-lock no-error.
                        if avail swibic then do:
                            swin.type = 'A'.
                            v-bank = swibic.name.
                        end.
                        if not avail swibic then swin.type = 'D'.
                        if remtrz.fcrc = 4 then do:
                            swin.type = 'D'.
                            find first swibic where swibic.bic = entry(2,remtrz.bb[1]," ") + "." + entry(3,remtrz.bb[1]," ") no-lock no-error.
                            if avail swibic then do:
                                v-bank = swibic.name.
                                v-city = swibic.city.
                                run rus-eng4ru(INPUT (v-bank), output  v-bank).
                                run rus-eng4ru(INPUT (v-city), output  v-city).
                            end.
                        end.
                        v571 = entry(1,remtrz.bb[1]," ") + " " + entry(2,remtrz.bb[1]," ").
                        v572 = entry(3,remtrz.bb[1]," ") + " " + entry(4,remtrz.bb[1]," ").
                        assign swin.content[1] = ' '.
                        if remtrz.fcrc <> 4 then do:
                            swin.content[2] = substr(v571,8,35).
                            swin.content[3] = substr(v-bank,1,35).
                            swin.content[4] = substr(v-bank,36,35).
                        end.
                        if remtrz.fcrc = 4 then do:
                            swin.content[1] = entry(1,remtrz.bb[1]," ") + entry(2,remtrz.bb[1]," ") + "." + entry(3,remtrz.bb[1]," ").
                            swin.content[2] = substr(v-bank,1,35).
                            swin.content[3] = substr(v-bank,36,35).
                            swin.content[4] = v-city.
                            if swin.content[3] = "" then do:
                                swin.content[3] = "G." + v-city.
                                swin.content[4] = "".
                            end.
                        end.
                    end.
                end.
                when '59' then /*assign swin.content[1] = remtrz.ba.*/ DO:
                    find first vcdocs where vcdocs.dnnum = substr(remtrz.remtrz,4,6) no-lock no-error.
                    if avail vcdocs then do:
                        find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                        if avail vccontrs then do:
                            find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
                            if avail vcpartner then v-partner = vcpartner.formasob + " " + vcpartner.name.
                        end.
                        find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                        if avail vccontrs then do:
                            assign swin.content[1] = "/" + substr(vccontrs.bankbacc,  1,35).
                            if vccontrs.inn <> "" then swin.content[2] = "INN" + substr(vccontrs.inn, 1,35).
                            if remtrz.fcrc <> 4 then do:
                                if swin.content[2] <> "" then do:
                                    swin.content[3] = substr(v-partner,1,35).
                                    swin.content[4] = substr(v-partner,36,35).
                                end. else do:
                                    swin.content[2] = substr(v-partner,1,35).
                                    swin.content[3] = substr(v-partner,36,35).
                                end.
                            end.
                            if remtrz.fcrc = 4 then do:
                                if swin.content[2] <> "" then do:
                                    run rus-eng4ru(substr(v-partner, 1,35), output v-str1).
                                    swin.content[3]  = v-str1.
                                    run rus-eng4ru(substr(v-partner, 36,35), output v-str2).
                                    swin.content[4] = v-str2.
                                end.
                                if swin.content[2] = "" then do:
                                    run rus-eng4ru(substr(v-partner, 1,35), output v-str1).
                                    swin.content[2]  = v-str1.
                                    run rus-eng4ru(substr(v-partner, 36,35), output v-str2).
                                    swin.content[3] = v-str2.
                                end.
                            end.
                        end.
                    end.
                    if swmt = '103' and remtrz.source = "IBH" then do:
                        v-tmp   = trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3]).
                        v-s1 = trim(substring( v-tmp, 001, 80 )).
                        run rus-eng4ru(INPUT (v-s1), output ruseng).
                        assign swin.content[1] = "/" + remtrz.ba
                               swin.content[2] = entry(1,ruseng,"/RNN/").
                        if remtrz.fcrc = 4 then do:
                            assign
                                swin.content[1] = "/" + remtrz.ba.
                                swin.content[2] = "INN" + substr(remtrz.bn[1],4,10).
                                swin.content[3] = substr(remtrz.bn[1],14,35).
                                swin.content[4] = substr(remtrz.bn[1],49,35).
                        end.
                    end.
                end.
                when '70' then DO:
                    find first vcdocs where vcdocs.dnnum = substr(remtrz.remtrz,4,6) no-lock no-error.
                    if avail vcdocs then do:
                        find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                        if avail vccontrs then do:
                            assign
                            swin.content[2] = "nomer kontrakta " + substr(vccontrs.ctnum,  1,35).
                            swin.content[3] = "data kontrakta " +  substr(string(vccontrs.ctdate), 1,35).
                            find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
                            if avail vcps then swin.content[4] = "nomer PS " +  substr((vcps.dnnum + string(vcps.num)), 1,35).
                        end.
                    end.
                    if swmt = '103' and remtrz.source = "IBH" then do:
                        v-detch = remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4].
                        run rus-eng4ru(INPUT (v-detch), output ruseng).
                        if remtrz.fcrc = 4 then do:
                            find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                            if avail sub-cod then do:
                                v-knp = substr(sub-cod.rcode,7,3).
                                if v-knp = "119" then v-add  = "(VO70070)".
                                else if v-knp matches "7*" then v-add = "(VO10030)".
                                else if v-knp matches "8*" then v-add = "(VO20020)". else v-add = "(VO99090)".
                                swin.content[1] = v-add + ruseng.
                            end.
                        end. else swin.content[1] = ruseng.
                        swin.content[2] = substr(ruseng,36,35).
                        swin.content[3] = substr(ruseng,71,35).
                        swin.content[4] = substr(ruseng,106,35).
                    end. else do:
                        swin.content[1] = ''.
                        swin.content[2] = ''.
                        swin.content[3] = ''.
                        swin.content[4] = ''.
                    end.
                end.
                when '71' then do:
                    if swmt = "100" then assign swin.content[1] = "OUR".
                    if swmt = "103" then do:
                        if f71=0 then assign swin.type="A" swin.content[1] = "OUR".
                        if f71=1 then assign tmps = "O" swin.type="F" swin.content[1] = "".
                    end.
                    f71 = f71 + 1.  /* Счетчик кол-ва полей */
                end.
                when '72' then do: /* sasco for RUB/RUR */
                    if crc.crc = 4 then
                      swin.content[1] = '/DAS/' + substr(string(year(remtrz.valdt2)), 3, 2) + string(month(remtrz.valdt2),"99") + string(day(remtrz.valdt2), "99") no-error.
                end.
            end case.
        end.
        /* Установим характеристики поля */
        assign
            swin.mandatory = tmps
            swin.descr     = swfield.descr
            swin.feature   = tmpf
            swin.length    = swfield.length
            swin.rmz     = s-remtrz.
        if swin.swfield = "71" and swin.type = "F" and swmt = "103" then swin.descr = "/sender's charges".
    end. /*** repeat ***/
end.
