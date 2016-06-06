/* vip_lst.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Формирование выписок по списку счетов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-4-12
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
                             оптимизация циклов
        17.04.2012 damir - формирование выписки на матричный принтер по нажатию кнопки <выписка>.
*/

{mainhead.i}

def new shared var p_vip   as char init "" format "x". /* "Выписка".  put vipiska   */
def new shared var p_mem   as char init "" format "x". /* " Мемориальный ордер" Put mem.ord.  */
def new shared var p_memf  as char init "" format "x". /* " Мемориальный ордер" Put mem.ord.  */
def new shared var p_pld   as char init "" format "x". /* Дебетовое платежное поручениеPut plat.por. deb.   */
def new shared var p_plc   as char init "" format "x". /* Кредитовое платежное поручение.  Put plat.por. kred.  */
def new shared var flg1    as logi.

def var v-file   as char init "stmtacc.lst". /* Список счетов в тек.директории */
def var in_acc   like aaa.aaa.
def var o_err    as logi init false.
def var v-print  as logi init true.
def var log_path as char format "x(150)".
def var dat1     as date format "99/99/9999".
def var dat2     as date format "99/99/9999".
def var v-vip    as char .

dat1 = g-today - 1.
dat2 = g-today - 1.

form
    dat1 label " Укажите дату начала периода" format "99/99/9999" validate (dat1 < g-today, " Начало периода не может быть позже чем закрытый день!") skip
    dat2 label "  Укажите дату конца периода" format "99/99/9999" validate (dat2 < g-today and dat2 >= dat1," Конец периода не может быть позже чем закрытый день/раньше начала периода")
with side-label row 5 centered frame dat.

displ dat1 dat2 with frame dat.
update dat1 with frame dat.
update dat2 with frame dat.

find sysc where sysc.sysc eq "BEGDAY" no-lock no-error.
if avail sysc and dat1 < sysc.daval then do:
    message "Начало периода не может быть позже чем "  sysc.daval.
    pause 10.
    return.
end.

unix silent rm -f value("vipiska.img").

{st_chkcif.i}

display " поиск счетов для формирования выписок... " with frame f-mess no-label centered row 11. pause 0.

for each sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnvip" and sub-cod.ccode = "1" no-lock:
    find first aaa where aaa.cif = sub-cod.acc /*and aaa.gl = 220310*/ and aaa.sta <> "C" no-lock no-error.
    if not avail aaa then next.
    if not chkcif (aaa.cif) then do:
        if not g-batch then do:
            find cif where cif.cif = aaa.cif no-lock no-error.
            message " Выписки по " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " не доступны для просмотра!".
            pause 5 no-message.
            hide message no-pause.
        end.
        next.
    end.
    goto1:
    for each aaa where aaa.cif = sub-cod.acc no-lock break by aaa.crc by aaa.cr[1] - aaa.dr[1]:
        if aaa.sta = "C" then next goto1.
        in_acc = aaa.aaa.
        message aaa.cif aaa.aaa view-as alert-box.
        find first jl where jl.acc = in_acc and jl.jdt >= dat1 and jl.jdt <= dat2 use-index jdtaccgl no-lock no-error.
        if not avail jl then next.
        /*display " формирование выписки по счету " in_acc skip(1) " за период " dat1 " - " dat2 with frame c3 no-label centered row 10 overlay. pause 0.*/
        run vip(in_acc,dat1,dat2,"1",p_mem,p_memf,p_pld,p_plc,output o_err).
        /*hide frame c3 no-pause.*/
    end.
end.
hide frame f-mess no-pause.
PAUSE 0 no-message.

/*v-vip = "stmt" + STRING(DAY(g-today),"99") + STRING(MONTH(g-today),"99") + SUBSTR(STRING(YEAR(g-today),"9999"),3,2) + ".txt".
if search("vipiska.img") ne ? then unix silent cp value("vipiska.img") value(v-vip).
unix silent rm -f value("vipiska.img").
message " Выписка записана в файл " v-vip.
pause 10.*/

if o_err then do:
    find sysc where sysc.sysc = "VIPLOG" no-lock no-error.
    if available sysc then log_path = trim(sysc.chval) + "/vip.log".
    else log_path = "vip.log".
    message " Смотрите протокол ошибок. " log_path.
end.

if not g-batch then do:
    pause 0.
    run menu-vip.
    pause 0 no-message.
end.

/*pause 0.
run menu-prt(v-vip).
pause 0 no-message.*/

/**/
procedure menu-vip.
    DEFINE VARIABLE msg  AS CHARACTER EXTENT 6.
    DEFINE VARIABLE i    AS INTEGER INITIAL 1.
    DEFINE VARIABLE ikey AS INTEGER INITIAL 1.
    DEFINE VARIABLE newi AS INTEGER INITIAL 1.

    DISPLAY SKIP(1)
    "[ВЫПИСКИ]"  @ msg[1] ATTR-SPACE format "x(7)"
    "[МЕМ.ОРДЕР]"    @ msg[2] ATTR-SPACE format "x(9)"
    "[МО+СЧЕТ-ФАКТ]"   @ msg[3] ATTR-SPACE format "x(12)"
    "[ПП ДЕБЕТ]"      @ msg[4] ATTR-SPACE format "x(8)"
    "[ПП КРЕДИТ]"       @ msg[5] ATTR-SPACE format "x(9)"
    "[ВЫХОД]"     @ msg[6] ATTR-SPACE format "x(5)"
    WITH CENTERED FRAME menu1 ROW 10 overlay NO-LABELS
    TITLE "[ ЧТО БУДЕМ ПЕЧАТАТЬ?! Выберите: ]".

    REPEAT WITH FRAME menu1:
        REPEAT:
            COLOR DISPLAY MESSAGES msg[i] WITH FRAME menu1.
            READKEY.
            CASE LASTKEY:
                WHEN KEYCODE("CURSOR-RIGHT") THEN DO:
                    newi = i + 1.
                    IF newi > 6 THEN newi = 1.
                END.
                WHEN KEYCODE("CURSOR-LEFT")  THEN DO:
                    newi = i - 1.
                    IF newi < 1 THEN newi = 6.
                END.
                WHEN KEYCODE("RETURN") THEN LEAVE.
                WHEN KEYCODE("GO")     THEN LEAVE.
            END CASE.
            IF i <> newi THEN COLOR DISPLAY NORMAL
            msg[i] WITH FRAME menu1.
            i = newi.
        END.

        CASE i:
            WHEN 1 THEN RUN menu-prt("vipiska.img").   /*unix value( "joe -rdonly " + cFile ).*/
            WHEN 2 THEN p_mem  = "1".     /*unix value( "prit  " + cFile ).*/
            WHEN 3 THEN p_memf = "1".    /*unix value( "cptw  " + cFile ). */
            WHEN 4 THEN p_pld  = "1".     /* unix value( "cptwo " + cFile ).*/
            WHEN 5 THEN p_plc  = "1".     /*unix value( "cptwd " + cFile ). */
            WHEN 6 THEN leave.
        END CASE.
    END.
    hide frame menu1.
end procedure.
/***/
