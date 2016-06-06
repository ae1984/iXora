/* cifdisp.p
 * MODULE
        Информация о клиентах и их счетах
 * DESCRIPTION
        Вывод на экран клиента информации по счету
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.1.1
 * AUTHOR
        10/07/2012 dmitriy
 * BASES
        BANK
 * CHANGES
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

{global.i}

def shared var s-cif like cif.cif.

def var acclist as char.
def var acclist2 as char.
def var v-sel as int.
def button prev-button label "Предыдущая".
def button next-button label "Следующая".
def button close-button label "Закрыть".
def var CurPage as int.
def var PosPage as int.
def var MaxPage as int.
def var phand AS handle.
def var Mask as char label "шаблон".
def var tmpl as char.
def var Pages as char.
def var t-res as char.

define frame Form1
    Mask format "x(25)" skip
    Pages skip
    "----------------------------------" skip
    prev-button next-button close-button
    WITH SIDE-LABELS centered overlay row 15 TITLE "Экран клиента".

def var list1 as char initial
    "246,151,152,153,154,155,156,157,158,171,172,173,174,175,160,161,249,204,202,208,222,247,248,176,177,130,131,132".

def var list2 as char initial
    "484,485,486,487,488,489,478,479,480,481,482,483,518,519,520,A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,B09,B10,B11,B15,B16,B17,B18,B19,B20".


find first cif where cif.cif = s-cif no-lock no-error.
if avail cif then do:
    for each aaa where aaa.cif = cif.cif and aaa.sta <> "C" no-lock:
        find first crc where crc.crc = aaa.crc no-lock no-error.
        if lookup (string(aaa.lgr), list1) > 0 then do:
            acclist = acclist + aaa.aaa + '|'.
            acclist2 = acclist2 + aaa.aaa + ' - текущий ' + crc.code + '|'.
        end.
        else if lookup (string(aaa.lgr), list2) > 0 then do:
            acclist = acclist + aaa.aaa + '|'.
            acclist2 = acclist2 + aaa.aaa + ' - сберегательный ' + crc.code + '|'.
        end.
    end.
end.

run sel2 ('Счета клиента',acclist2, output v-sel).

find first aaa where aaa.aaa = entry(v-sel, acclist,'|') and aaa.sta <> "C" no-lock no-error.
if avail aaa then do:
    if lookup (string(aaa.lgr), list1) > 0 then do:
        run screen(1, aaa.aaa).
    end.

    else if lookup (string(aaa.lgr), list2) > 0 then do:
        run screen(2, aaa.aaa).
    end.
end.
else do:
    message "Счет не найден".
    pause 5.
end.



procedure screen:
    def input parameter t-screen as int.
    def input parameter v-acc as char.

    case t-screen:
        when 1 then do:
            tmpl = "newaaa1,aaadepo2".
            Mask = "Открытие  текущего счета".
            MaxPage = 2.
        end.
        when 2 then do:
            tmpl = "newdepo1,aaadepo2".
            Mask = "Открытие сберегательного счета".
            MaxPage = 2.
        end.
    end case.

        CurPage = 1.
        PosPage = 1.

        Pages = "1 из " + string(MaxPage).
        DISPLAY Pages Mask WITH FRAME Form1.

        run sel_screen(entry(1, tmpl, ","), s-cif, v-acc, output t-res).
        run to_screen(entry(1, tmpl, ","), t-res).


        ON CHOOSE OF next-button
        DO:
            PosPage = PosPage + 1.
            if PosPage > MaxPage then PosPage = MaxPage.
            Pages = string(PosPage) + " из " + string(MaxPage).

            if PosPage = 1 then do:
                run sel_screen(entry(1, tmpl, ","), s-cif, v-acc, output t-res).
                run to_screen(entry(1, tmpl, ","), t-res).
            end.
            else do:
                run sel_screen(entry(PosPage, tmpl, ","), s-cif, v-acc, output t-res).
                run to_screen(entry(PosPage, tmpl, ","), t-res).
            end.
            DISPLAY Pages Mask WITH FRAME Form1.
        END.

        ON CHOOSE OF prev-button
        DO:
            PosPage = PosPage - 1.
            if PosPage <= 0 then PosPage = 1.
            Pages = string(PosPage) + " из " + string(MaxPage).

            if PosPage = 1 then do:
                run sel_screen(entry(1, tmpl, ","), s-cif, v-acc, output t-res).
                run to_screen(entry(1, tmpl, ","), t-res).
            end.
            else do:
                run sel_screen(entry(PosPage, tmpl, ","), s-cif, v-acc, output t-res).
                run to_screen(entry(PosPage, tmpl, ","), t-res).
            end.
            DISPLAY Pages Mask WITH FRAME Form1.
        END.

        ON CHOOSE OF close-button
        DO:
            run to_screen( "default","").
            apply "endkey" to frame Form1.
            hide frame Form1.
            return.
        END.

        /*Pages = string(PosPage) + " из " + string(MaxPage).*/

            DISPLAY Pages prev-button next-button close-button WITH FRAME Form1.
            ENABLE next-button  prev-button  close-button WITH FRAME Form1.

        WAIT-FOR endkey of frame Form1.
        hide frame Form1.
end procedure.