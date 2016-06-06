/* bccur.p
 * MODULE
        Параметры системы
 * DESCRIPTION
        Курсы Нац. Банка
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
        bccur2fil.p
 * MENU
        9-1-2-2-1
 * BASES
        BANK COMM
 * AUTHOR
        30/01/2002 sasco
 * CHANGES
        01.10.2002 nadejda добавлены данные о замене неактуальной валюты
        21.11.2002 nadejda добавлено копирование на филиалы при изменении важных данных (курс, код...)
        24.05.2003 nadejda - убраны параметры -H -S из коннекта
        18.09.2003 nadejda - менять rate[1], десятичные доли и размерность разрешается только суперюзерам (на всех базах) и ДИТ (в Головном офисе)
                             поставила копирование курса rate[1] в таблицу курсов НБ РК
        06.09.2004 dpuchkov - добавил рассылку сообщений пользователям при смене курсов валют
        23.09.2004 dpuchkov - отправка распоряжений
        29.09.2004 dpuchkov - обавил курсы на 9-00.
        22.02.2006 u00121   - формирование файла с курсами валют для экранов в Операционном департаменте, адреса экранов находятся в sysc = plscrc
        14.02.2006 u00121   - добавил вопрос "Обновить мониторы валют?" после смены курсов
        20.03.2006 u00121   - убрана перекодировка файла для плазменных мониторов курсов валют
        09.06.2006 Ten      - Автоматическая сверка курсов валют.
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        31.10.2006 u00124   - изменил название файла irtext.txt
        01.11.2006 u00124   - перерисовал файл с курсами валют под новую программу.
        01.11.2006 suchkov - изменен алгоритм учета времени создания записи
        06.11.2006 u00124  - добавил перекодировку un-win
        04/03/08 marinav - перевод цикла на r-branch, изменение адресов
        08.05.2008 alex - экспорт курса валют на сайт
        05.06.08 marinav - убрала из подсказки слова Р-печать
        19.08.2008 id00024 - добавил дополнительное условие для логической переменной v-chng
        30.01.2009 id00209 - нумерация распоряжений, закомментил RSH.
        24/03/2009 madiyar - удалил все лишнее, связанное с мониторами и нетсендами; вынес нумерацию распоряжений в rasp.p
        26/03/2009 madiyar - распоряжения рассылаются и в филиалах
        30/05/2009 id00004 - добавил отправку курсов в соник
        15/02/2011 id00004 - изменил параметры отправки курсов в sonic.
        24.03.2011 aigul - добавила проверку курсов с опрными курсами.
        22.04.2011 aigul - проверка на начало дня, если да то ввести в бд все валюты даже если они не были изменены, если нет то ввести в бд только измененные курсы
        10.05.2011 aigul - копировать курсы на сайт с Алматинского филиала
        17.05.2011 id00004 - сделал отпраку курсов в соник с флм филиала вместо ЦО
        21.07.2011 aigul - исправила update crc.rate[2] crc.rate[3] изменение значений друг за другом.
        22.07.2011 aigul - recompile for crc.f
        25.07.2011 aigul - не формировать рапоряжение для bankadm и администарторов
        08.08.2011 aigul - добавила запсиь tcrc офицера
        09.08.2011 aigul - записать в справочник о смене курсов
        10.08.2011 aigul - перенесла запись в справочник о смене курсов в rasp.p
        11.08.2011 aigul - recompile
        11.08.2011 aigul - добавила вызов menu-bccur.p
        15.08.2011 aigul - recompile
        06.10.2011 lyubov - поле «курс KZT» доступно для редактирования только сотрудникам ДИТ (профит-центр 508)
        14/01/2012 evseev - если today > g-today, то время 99998
        26.09.2013 damir - Внедрено Т.З. № 2109. Добавил JMS-MAXIMUM-MESSAGES.
*/

{mainhead.i}
{comm-txb.i}
{get-dep.i}
{srvcheck.i}

def var v-log as log no-undo.
def buffer t12c for crc.
def var rr5 as int no-undo.
def new shared var t9 as char format "x(1)".
def new shared frame crc.
def var t5 as int no-undo.
def var t4 as char initial "F4-выход,INS-дополн." no-undo.
def var v-chng as logical no-undo.
def var v-chngrate1 as logical no-undo.
def var v-center as logical no-undo.
def var v-center1 as logical no-undo.
def var vp-t9 as char format "x(1)" no-undo.
def var v-bank as char no-undo.

def temp-table t-crc no-undo like crc.
def temp-table ofccrc no-undo like crc.

def var upd-it as log init true no-undo.
def var v-chngcrc as logical init no no-undo.

def buffer bcrc for crc.
def stream v-out.

/*
def temp-table temp no-undo
         field crc as int
         field des as char
         field rate1 as dec
         field rate2 as dec.
*/

def var v-sysc as int initial 0.
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-chk1 as logic no-undo.
def var v-chk2 as logic no-undo.
v-chk1 = no.
v-chk2 = no.
function is_crc_changed returns logical.
    def var v-ch as logical no-undo init no.
    for each crc no-lock:
    if (crc.crc = 1) or (crc.crc = 5) then next.
        /*find last ofccrc where ofccrc.crc = crc.crc no-lock no-error.
        if avail ofccrc then do:*/
        /*курсы на начало дня 9-00*/
            /*if crc.crc = 2 or crc.crc = 3 or crc.crc = 4  or crc.crc = 6 then do:
                find last tcrc where tcrc.whn = g-today and tcrc.crc = crc.crc no-lock no-error.
                if not avail tcrc then do:
                    create tcrc.
                    assign
                        tcrc.crc = crc.crc
                        tcrc.rate[2] = ofccrc.rate[2]
                        tcrc.rate[3] = ofccrc.rate[3]
                        tcrc.dtime = 32400.
                        tcrc.whn = g-today.
                end.
            end.
         end.*/
         find first sysc where sysc.sysc = "bday" and sysc.loval = yes no-lock no-error.
         if avail sysc  then v-chk1 = yes.
         if v-chk1 then do:
            find last crchis where crchis.crc = crc.crc no-lock no-error.
            if avail crchis then do:
                create tcrc.
                assign tcrc.crc = crc.crc
                       tcrc.rate[2] = crchis.rate[2]
                       tcrc.rate[3] = crchis.rate[3]
                       tcrc.dtime = time
                       tcrc.whn = g-today.
                       tcrc.who = g-ofc.
                       v-ch = yes.
            end.
         end.
         for each ofccrc where ofccrc.crc = crc.crc no-lock:
            find first sysc where sysc.sysc = "bday" and sysc.loval = no no-lock no-error.
            if avail sysc  then v-chk1 = no.
            if v-chk1 = no and v-chk2 = no then do:
                if crc.rate[2] <> ofccrc.rate[2] or crc.rate[3] <> ofccrc.rate[3] or crc.rate[4] <> ofccrc.rate[4] or crc.rate[5] <> ofccrc.rate[5] or
                   crc.rate[6] <> ofccrc.rate[6] or crc.rate[7] <> ofccrc.rate[7] or crc.rate[8] <> ofccrc.rate[8] or crc.rate[9] <> ofccrc.rate[9] then do:
                    find last crchis where crchis.crc = crc.crc no-lock no-error.
                    if avail crchis then do:
                        create tcrc.
                        assign tcrc.crc = crc.crc
                               tcrc.rate[2] = crchis.rate[2]
                               tcrc.rate[3] = crchis.rate[3]
                               tcrc.dtime = time
                               tcrc.whn = g-today.
                               tcrc.who = g-ofc.
                        v-ch = yes.
                    end.
                end.
            end.
         end.
    end.
    if v-chk1 = yes then do:
    find first sysc where sysc.sysc = "bday" exclusive-lock no-error.
    if avail sysc then  sysc.loval = no.
    find first sysc where sysc.sysc = "bday" no-lock no-error.
    end.
    return v-ch.
end function.


for each crc no-lock.
    create ofccrc.
    buffer-copy crc to ofccrc.
end.

v-center = (s-ourbank = "txb00").
v-center1 = (s-ourbank = "txb16").
/* 18.09.2003 nadejda - менять rate[1], десятичные доли и размерность разрешается только суперюзерам (на всех базах) и ДИТ (в Головном офисе) */
def var v-availupd as logical no-undo.
find last sysc where sysc.sysc = "SUPUSR" no-lock no-error.
v-availupd = (avail sysc and lookup(g-ofc, sysc.chval) > 0).

if v-center and not v-availupd then do:
    find last ofc where ofc.ofc = g-ofc no-lock no-error.
    find last sysc where sysc.sysc = "CURSD" no-lock no-error.
    v-availupd = (avail ofc and lookup(ofc.titcd, sysc.chval) > 0).
end.
{apbra.i
&head = "crc"
&headkey = "crc"
&index = "crc no-lock"
&formname = "crc"
&framename = "crc"
&where = "crc.sts <> 9"
&addcon = "true"
&deletecon = "false"
&postadd = "find last t12c use-index crc no-error.
            rr5 = t12c.crc + 1.
            crc.crc = rr5.
            t9 = ' '.
            crc.rate[9] = 1.
            run crcupd-before.
            do on endkey undo, leave:
                 update crc.des crc.rate[1] crc.rate[9] crc.decpnt crc.code t9
                      with frame crc.
                 update crc.rate[2] crc.rate[3] crc.rate[4] crc.rate[5] crc.rate[6] crc.rate[7]
                      with frame rate.
              run crcupd-after.
            end.
            find last crchis where crchis.crc = crc.crc and crchis.rdt = crc.regdt no-lock no-error.
            display crchis.rdt with frame crc.
            run copy2fil.
"
&prechoose = "message t4."
&predisplay = " find last crchis where crchis.crc = crc.crc no-lock no-error.
find crchs where crchs.crc = crc.crc no-lock no-error.
if available crchs then t9 = crchs.Hs. else t9 = ' '.  "
&display = "crc.crc crc.des crc.rate[1] crc.rate[9] crc.decpnt
    crchis.rdt when available crchis  crc.code t9"
&highlight = " crc.crc crc.des "
&predelete = " "
&postdelete = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
                run crcupd-before.
                do transaction on endkey undo, leave:
                    find current crc exclusive-lock.
                    if crc.crc <> 2 and crc.crc <> 4 and crc.crc <> 3 then do:
                        update crc.des with frame crc.

                        find first ofc where ofc.ofc = g-ofc no-lock no-error.
                            if avail ofc then
                            if ofc.titcd = '508' then
                            update crc.rate[1] with frame crc.

                        update crc.rate[9] when v-availupd crc.decpnt when v-availupd crc.code t9 with frame crc.
                        update crc.rate[2] crc.rate[3] crc.rate[4] crc.rate[5] crc.rate[6] crc.rate[7] with frame rate.
                        run crcupd-after.
                    end.
                    else do:
                        update crc.des with frame crc.

                        find first ofc where ofc.ofc = g-ofc no-lock no-error.
                            if avail ofc then
                            if ofc.titcd = '508' then
                            update crc.rate[1] with frame crc.

                        update crc.rate[9] when v-availupd crc.decpnt when v-availupd crc.code t9 with frame crc.
                        update crc.rate[2] with frame rate.
                        update crc.rate[3] with frame rate.
                        update crc.rate[4] crc.rate[5] crc.rate[6] crc.rate[7] with frame rate.
                        run crcupd-after.
                    end.
                    find current crc no-lock.
                    find sysc where sysc.sysc = 'SCRC' exclusive-lock.
                        sysc.daval = today.
                        if index(sysc.chval, string(crc.crc)) > 0 then do:
                            d = substr(sysc.chval, index(sysc.chval, string(crc.crc)), 3).
                            sysc.chval  = REPLACE(sysc.chval , d, substr(d,1,1) + '-0').
                        end.
                    find sysc where sysc.sysc = 'SCRC' no-lock.

                end.
                find last crchis where crchis.crc = crc.crc and crchis.rdt = crc.regdt no-lock no-error.
                display crchis.rdt with frame crc.

                do transaction:
                    run copy2nb.
                end.
                run copy2fil.

            end.
            "
&end = "hide frame crc.  "
}




if v-center1 then run copy2site.

/*  09.06.2006 Ten  Отчет по исправленным курсам */
/*
find first temp where temp.crc <> 0 no-error.
if avail temp then do:
    output to kursy.htm.
    put unformatted "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                    "<head><title>лерпнйнлаюмй</title>" skip
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip.
    put unformatted "<center> <font size=2><P> яОХЯНЙ ХГЛЕМЕММШУ ЙСПЯНБ БЮКЧР ОН ЯНЯРНЪМХЧ МЮ " g-today " ЦНДЮ </font></center>" skip.
    put unformatted "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
                    "<tr><td align=center > бЮКЧРЮ </td>" skip
                    "<td align=center > йСПЯ(ХГЛЕМЕМММШИ) </td>" skip
                    "<td align=center > йСПЯ(ОПНЦМНГМШИ) </td></tr>" skip.

    for each temp where temp.crc <> 0.
        if temp.crc = 2 then temp.des = "дНККЮПШ яью".
        else
        if temp.crc = 4 then temp.des = "пНЯЯХИЯЙХЕ ПСАКХ".
        else
        if temp.crc = 3 then temp.des = "еБПН".


        put unformatted
                        "<tr><td align=center>" temp.des   " </td>" skip
                        "<td align=center >"    temp.rate2 "</td>" skip
                        "<td align=center >"    temp.rate1 "</td></tr>" skip.
    end.
    put unformatted "</table>" skip
                    "</html>"  skip.
    run mail  ("id00172@metrocombank.kz,id00005@metrocombank.kz,","МЕТРОКОМБАНК <abs@metrocombank.kz>","Измененные курсы валют"," См. вложение ","1","","kursy.htm").
    run mail  ("id00776@metrocombank.kz; id00820@metrocombank.kz; id00876@metrocombank.kz", "МЕТРОКОМБАНК <abs@metrocombank.kz>","Измененные курсы валют"," См. вложение ","1","","kursy.htm").
end.
*/

hide message.

procedure check:
    def var v-buy as decimal.
    def var v-sell as decimal.
    def var v-spred as decimal.
    def var v-order as int.
    def var v-crc as int.
    def var v-chk as logical initial no.
    def buffer b-scrc for scrc.
    def var d as char format "x(50)".
    for each crc no-lock:
        for each scrc where scrc.crc = crc.crc no-lock break by scrc.scrc:
            find last b-scrc where b-scrc.scrc = scrc.scrc no-lock no-error.
            if avail b-scrc then do:
                v-buy = b-scrc.buy.
                v-sell = b-scrc.sell.
                v-spred = b-scrc.minspr.
                v-chk = yes.
                v-order = b-scrc.order.
                v-crc = b-scrc.crc.
            end.
        end.
    end.
    if v-chk then do:
        for each crc where crc.crc = v-crc no-lock:
            if crc.rate[2] > v-buy or crc.rate[3] < v-sell or crc.rate[3] - crc.rate[2] < v-spred then do:
                message 'Не все курсы валют установлены в соответствии с опорными курсами!' view-as alert-box.
            end.
            find sysc where sysc.sysc = 'SCRC' exclusive-lock.
                sysc.daval = today.
                if index(sysc.chval, string(crc.crc)) > 0 then do:
                    d = substr(sysc.chval, index(sysc.chval, string(crc.crc)), 3).
                    sysc.chval  = REPLACE(sysc.chval , d, substr(d,1,1) + "-0").
                end.
            find sysc where sysc.sysc = 'SCRC' no-lock.
        end.
    end.
end procedure.
run pechcrc.
/*run check.*/
/*run menu-prt1 ("rpt.img").*/
run menu-bccur ("rpt.img").
v-chngcrc = is_crc_changed().


/*делать рассылку только если это ЦО и курсы действительно были изменены*/

if v-chngcrc and /*(g-ofc <> "bankadm" or g-ofc <> "id00700" or g-ofc <> "id00477")*/
(g-ofc <> "bankadm" and g-ofc <> "id00700" and g-ofc <> "id00477") /*and v-center*/ then run rasp.

 run rate_toscr.

/* Формируем сообщения для для соника */
do transaction:
    def buffer b-ssc for sysc.
    def buffer b-ss for sysc.
    if v-chngcrc then do:
        find last sysc where sysc.sysc = "OURBNK" no-lock no-error.
        if sysc.chval = "TXB16" then do:
            find b-ss where b-ss.sysc= "KNSB" exclusive-lock no-error.
            def buffer b-crcc for crc.
            def buffer b-sonic for sysc.
            DEFINE VARIABLE ptpsession AS HANDLE.
            DEFINE VARIABLE messageH AS HANDLE.

            DEFINE NEW GLOBAL SHARED VAR JMS-MAXIMUM-MESSAGES AS INTEGER INIT 500.
            /*run jms/jmssession.p persistent set ptpsession ("-SMQConnect").*/
            RUN jms/ptpsession.p PERSISTENT SET ptpsession ("").
            if isProductionServer() then do:
                run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
            end.
            else do:
                run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").
            end.

            /*      find last b-sonic where b-sonic.sysc = "soniclogin" no-lock no-error. */
            run setUser in ptpsession ("SonicClient").
            /*      find last b-sonic where b-sonic.sysc = "sonicpasswd" no-lock no-error. */
            run setPassword in ptpsession ("SonicClient").
            RUN beginSession IN ptpsession.
            for each b-crcc where b-crcc.crc = 2 or b-crcc.crc = 3 or b-crcc.crc = 4 no-lock :
                if avail b-ss then do:
                    if g-today = date(b-ss.chval) then do:
                    end.
                    else do:
                        RUN createTextMessage IN ptpsession (OUTPUT messageH).
                        RUN setStringProperty IN messageH ("CURRENCY", b-crcc.code).
                        RUN setStringProperty IN messageH ("TYPE", "NB").
                        RUN setStringProperty IN messageH ("DATE",    string(substr(string(g-today),1,2)) + "." + string(substr(string(g-today),4,2)) + "." + string(year(g-today)) +  " " + string(time , "hh:mm")) .
                        RUN setStringProperty IN messageH ("AMOUNT", string(b-crcc.rate[1])).
                        RUN setStringProperty IN messageH ("NOMINAL", "1").
                        RUN sendToQueue IN ptpsession ("CURRENCY_RATE", messageH, ?, ?, ?).
                    end.
                end.
                else do:
                    RUN createTextMessage IN ptpsession (OUTPUT messageH).
                    RUN setStringProperty IN messageH ("CURRENCY", b-crcc.code).
                    RUN setStringProperty IN messageH ("TYPE", "NB").
                    RUN setStringProperty IN messageH ("DATE",    string(substr(string(g-today),1,2)) + "." + string(substr(string(g-today),4,2)) + "." + string(year(g-today)) +  " " + string(time , "hh:mm")) .
                    RUN setStringProperty IN messageH ("AMOUNT", string(b-crcc.rate[1])).
                    RUN setStringProperty IN messageH ("NOMINAL", "1").
                    RUN sendToQueue IN ptpsession ("CURRENCY_RATE", messageH, ?, ?, ?).
                end.
                RUN createTextMessage IN ptpsession (OUTPUT messageH).
                RUN setStringProperty IN messageH ("CURRENCY", b-crcc.code).
                RUN setStringProperty IN messageH ("TYPE", "BUY").
                RUN setStringProperty IN messageH ("DATE",  string(substr(string(g-today),1,2)) + "." + string(substr(string(g-today),4,2)) + "." + string(year(g-today)) +  " " + string(time , "hh:mm")) .
                RUN setStringProperty IN messageH ("AMOUNT", string(b-crcc.rate[2])).
                RUN setStringProperty IN messageH ("NOMINAL", "1").
                RUN sendToQueue IN ptpsession ("CURRENCY_RATE", messageH, ?, ?, ?).
                RUN createTextMessage IN ptpsession (OUTPUT messageH).
                RUN setStringProperty IN messageH ("CURRENCY", b-crcc.code).
                RUN setStringProperty IN messageH ("TYPE", "SALE").
                RUN setStringProperty IN messageH ("DATE",  string(substr(string(g-today),1,2)) + "." + string(substr(string(g-today),4,2)) + "." + string(year(g-today)) +  " " + string(time , "hh:mm")) .
                RUN setStringProperty IN messageH ("AMOUNT", string(b-crcc.rate[3])).
                RUN setStringProperty IN messageH ("NOMINAL", "1").
                RUN sendToQueue IN ptpsession ("CURRENCY_RATE", messageH, ?, ?, ?).
                RUN createTextMessage IN ptpsession (OUTPUT messageH).
                RUN setStringProperty IN messageH ("CURRENCY", b-crcc.code).
                RUN setStringProperty IN messageH ("TYPE", "KASE").
                RUN setStringProperty IN messageH ("DATE",  string(substr(string(g-today),1,2)) + "." + string(substr(string(g-today),4,2)) + "." + string(year(g-today)) +  " " + string(time , "hh:mm")) .
                RUN setStringProperty IN messageH ("AMOUNT", string(b-crcc.rate[1])).
                RUN setStringProperty IN messageH ("NOMINAL", "1").
                RUN sendToQueue IN ptpsession ("CURRENCY_RATE", messageH, ?, ?, ?).
            end.
            RUN deleteMessage IN messageH.
            RUN deleteSession IN ptpsession.
        end.
        if avail b-ss then b-ss.chval = string(g-today).
    end.
/* Формируем сообщения для для соника */
end.

/*---procedures-----------------------------------------------------------------------------------*/

procedure crcupd-before.
    buffer-copy crc to t-crc.
    find crchs where crchs.crc = crc.crc no-lock no-error.
    if available crchs then t9 = crchs.Hs.
    else t9 = ' '.
    vp-t9 = t9.
end procedure.

procedure crcupd-after.
  def var v-newhis as logical init false no-undo.
  crc.regdt = g-today.

  find crchs where crchs.crc = crc.crc no-error.
  if not available crchs then do:
    create crchs.
    crchs.crc = crc.crc.
  end.
  crchs.Hs = t9.


  if g-today < today then do:
     find first crchis where  crchis.crc = crc.crc and crchis.rdt = g-today and crchis.tim = 99998 no-error.
     if avail crchis then delete crchis.
  end.

    create crchis.
    v-newhis = true.

  buffer-copy crc to crchis.

  crchis.rdt = crc.regdt.
  crchis.who = g-ofc.
  crchis.whn = g-today.
  if g-today > today then crchis.tim = 60 .
                     else crchis.tim = time .

  if g-today < today then crchis.tim = 99998 .

  v-chng = v-center and
/* ********** 19.08.2008 id00024 ******** */
    (v-newhis or crc.rate[1] <> t-crc.rate[1] or crc.rate[2] <> t-crc.rate[2] or crc.rate[3] <> t-crc.rate[3] or crc.rate[4] <> t-crc.rate[4] or crc.rate[5] <> t-crc.rate[5] or crc.des <> t-crc.des or
/* *************************** */
     crc.rate[9] <> t-crc.rate[9] or crc.decpnt <> t-crc.decpnt or
     crc.code <> t-crc.code or vp-t9 <> t9).

  v-chngrate1 = v-newhis or
                (crc.rate[1] <> t-crc.rate[1] or
                 crc.rate[9] <> t-crc.rate[9] or
                 crc.decpnt  <> t-crc.decpnt).
end procedure.

/* переписать изменение rate[1] в таблицу валют НБ РК (теперь средневзвешенный является и официальным тоже) */
procedure copy2nb.
  def var v-ch as logical no-undo.

  if v-chngrate1 then do:
    v-ch = false.

    find ncrc where ncrc.crc = crc.crc exclusive-lock no-error.
    if avail ncrc then do:
      if ncrc.rate[1] <> crc.rate[1] then assign v-ch = true ncrc.rate[1] = crc.rate[1].
      if ncrc.rate[9] <> crc.rate[9] then assign v-ch = true ncrc.rate[9] = crc.rate[9].
      if ncrc.decpnt  <> crc.decpnt  then assign v-ch = true ncrc.decpnt  = crc.decpnt.
      if ncrc.regdt   <> crc.regdt   then assign v-ch = true.
      /* скопировать в историю */
      if v-ch then do:
        ncrc.regdt = g-today.

  if g-today < today then do:
     find first ncrchis where  ncrchis.crc = ncrc.crc and ncrchis.rdt = g-today and ncrchis.tim = 99998 no-error.
     if avail ncrchis then delete ncrchis.
  end.

        create ncrchis.
        buffer-copy ncrc to ncrchis.

        assign ncrchis.rdt = ncrc.regdt
               ncrchis.who = g-ofc
               ncrchis.whn = g-today
               ncrchis.tim = time.
        if g-today < today then ncrchis.tim = 99998 .
      end.
    end.
  end.
end procedure.

/* переписать важные изменения с головного на филиалы */

procedure copy2fil.
  if v-chng then do:
    {r-branch.i &proc = "bccur2fil (bank.crc.crc)"}
  end.
end procedure.

/* переписать изменения на сайт */
procedure copy2site.

        output stream v-out to rates.js.
        put stream v-out unformatted
            "var DT = """ + string(today, "99.99.9999")  + """;" skip
            "var DTY = """ + string(today - 1, "99.99.9999") + """;" skip.

        find first bcrc where bcrc.crc = 2 no-lock no-error.
        if avail(bcrc) then put stream v-out unformatted
            "var CB_USD_TOD = """ + trim(string(bcrc.rate[1], ">>>9.99")) + """;" skip
            "var MB_USD_BUY_C = """ + trim(string(bcrc.rate[2], ">>>9.99")) + """;" skip
            "var MB_USD_SELL_C = """ + trim(string(bcrc.rate[3], ">>>9.99")) + """;" skip.
        find last crchis where (crchis.crc = 2) and (crchis.regdt <= today) no-lock no-error.
        if avail(crchis) then put stream v-out unformatted
            "var CB_USD_YST = """ + trim(string(crchis.rate[1], ">>>9.99")) + """;" skip.

        find first bcrc where bcrc.crc = 3 no-lock no-error.
        if avail(bcrc) then put stream v-out unformatted
            "var CB_EUR_TOD = """ + trim(string(bcrc.rate[1], ">>>9.99")) + """;" skip
            "var MB_EUR_BUY_C = """ + trim(string(bcrc.rate[2], ">>>9.99")) + """;" skip
            "var MB_EUR_SELL_C = """ + trim(string(bcrc.rate[3], ">>>9.99")) + """;" skip.
        find last crchis where (crchis.crc = 3) and (crchis.regdt <= today) no-lock no-error.
        if avail(crchis) then put stream v-out unformatted
            "var CB_EUR_YST = """ + trim(string(crchis.rate[1], ">>>9.99")) + """;" skip.

        find first bcrc where bcrc.crc = 4 no-lock no-error.
        if avail(bcrc) then put stream v-out unformatted
            "var CB_RUR_TOD = """ + trim(string(bcrc.rate[1], ">>>9.99")) + """;" skip
            "var MB_RUR_BUY_C = """ + trim(string(bcrc.rate[2], ">>>9.99")) + """;" skip
            "var MB_RUR_SELL_C = """ + trim(string(bcrc.rate[3], ">>>9.99")) + """;" skip.
        find last crchis where (crchis.crc = 4) and (crchis.regdt <= today) no-lock no-error.
        if avail(crchis) then put stream v-out unformatted
            "var CB_RUR_YST = """ + trim(string(crchis.rate[1], ">>>9.99")) + """;" skip.

        output stream v-out close.
        unix silent value("cp ./rates.js /data/export/currency").

end procedure.
