/* show-crc.p
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
        13.04.2012 aigul - добавила новые курсы валют, output only in excel
        02.05.2012 aigul - исправила вывод валюты
*/

/*
    09.06.2000
    show-crc.p
    Справка по курсам валют за период...
    а также по курсам покупки-продажи за период ...
    Подлипалина Е.Ф.

    06/02/2002 sasco:  настройка принтера из OFC.
                       курсы валют - по НацБанку! ! !
    18.03.2011 damir - добавил if avail ncrchis - выходила ошибка

*/

{global.i}
def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999".
def var vakod as int.
def var val_name as char.
def var v-code as char.
def var v-des as char.
find last cls no-lock no-error.
g-today = if available cls then cls.cls + 1 else today.
dat1 = today.
dat2 = today.
unix silent rm -f value("valut.txt").
update dat1 label ' Укажите дату начала периода' format '99/99/9999' skip
dat2 label ' Укажите дату конца периода ' format '99/99/9999' skip
with side-label row 5 centered frame datokn.
if dat1 = dat2 then do:
    /*output to valut1.cvs.*/
    def stream valut1.
    output stream valut1 to valut1.html.
    {html-title.i
    &title = "Курсы валют Нац. банка" &stream = "stream valut1" &size-add = "x-"}
    /*hide frame datokn.*/
    /*message 'ха - ха'.*/
    put stream valut1 unformatted
    "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
    "<B>[ Курсы валют Нац. банка на" + string(dat1, "99/99/9999")  + ' г, ' + string( time,'hh:mm:ss' ) + "]</FONT></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
    put stream valut1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Курс</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Установлен</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Наименование</B></FONT></TD>" skip
    "</TR>" skip.
    if dat1 >= 01/05/12 then do:
        for each ncrc no-lock:
            find last crcpro where crcpro.crc = ncrc.crc and crcpro.regdt = dat1 no-lock no-error.
            if avail crcpro then do:
                find first crc where crc.crc = crcpro.crc no-lock no-error.
                if avail crc then do:
                    v-code = crc.code.
                    v-des = crc.des.
                end.
                put stream valut1 unformatted
                "<TR align=""center"">" skip
                "<TD><FONT size=""2""><B>" + string(crcpro.crc) + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + v-code + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + replace(string(crcpro.rate[1]),".",",")    + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + string(crcpro.regdt,"99/99/9999") + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + v-des + "</B></FONT></TD>" skip.
            end.
        end.
    end.
    if dat1 <= 01/05/12 then do:
        for each ncrc no-lock:
            find last ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt = dat1 no-lock no-error.
            if avail ncrchis then do:
                put stream valut1 unformatted
                "<TR align=""center"">" skip
                "<TD><FONT size=""2""><B>" + string(ncrchis.crc) + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + ncrc.code + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + replace(string(ncrchis.rate[1]),".",",")    + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + string(ncrchis.rdt,"99/99/9999") + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + ncrc.des  + "</B></FONT></TD>" skip.
            end.
        end.
    end.
    put stream valut1 unformatted
    "</TABLE>" skip.

    {html-end.i "stream valut1" }

    output stream valut1 close.
    unix silent cptwin valut1.html excel.exe.
    pause 0.
    /*display
    skip(1) 'Валюта        Курс  Установлен Наименование                  '
    skip(1) with side-label centered frame headers title '[ Курсы валют Нац. банка на ' + string( dat1, '99/99/9999' ) + ' г, ' + string( time,'hh:mm:ss' ) + ' ]'.
    def new shared var t9 as char format "x(1)".
    for each ncrc no-lock:*/
        /*find last ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt <= dat1 no-lock no-error.
        if avail ncrchis then do:
        display
        ncrchis.crc     no-label
        ncrc.code       no-label
        ncrchis.rate[1] no-label
        ncrchis.rdt     no-label
        ncrc.des        no-label with centered.
        end.*/
       /* find last crcpro where crcpro.crc = ncrc.crc and crcpro.regdt <= dat1 no-lock no-error.
        if avail crcpro then do:
            find first crc where crc.crc = crcpro.crc no-lock no-error.
            if avail crc then do:
                v-code = crc.code.
                v-des = crc.des.
            end.
            display
            crcpro.crc     no-label
            v-code       no-label
            crcpro.rate[1] no-label
            crcpro.regdt     no-label
            v-des        no-label with centered.
        end.
    end.*/
    /* прогонка принтера, чтобы бумагу не выкручивать вручную */
    /*find first ofc where ofc.ofc = userid('bank').
    if ofc.mday[2] = 1 then put skip(14).
    else put skip(1).

    output close.
    pause 0 before-hide.
    run menu-prt('valut1.cvs').*/

/* ********************************************************************** */
/* Курсы покупки-продажи убраны, так как их по НацБанку никто не апдейтит */
/*     displ 'А теперь курсы покупки-продажи' with centered row 01 frame bbb.
     if dat1 = g-today then run pechncrc.
     else do:
            output to rpt.img.
            for each ncrchs:
            find ncrc where ncrc.crc = ncrchs.crc no-lock no-error.
            if not available ncrc then delete ncrchs.
            end.

            display dat1 label "Дата : " with side-labels .
            for each ncrc where ncrc.sts <> 9 no-lock:
               find ncrchs where ncrchs.crc = ncrc.crc no-lock no-error.
               t9 = ncrchs.Hs.
               find last ncrchis where ncrc.crc = ncrchis.crc and
                                       ncrchis.rdt <= dat1 no-lock no-error.
               display ncrc.crc label 'Вал'
               ncrc.des label " Наименование валюты " format "x(25)"
               ncrchis.rate[1] label "Курс тенге"
               ncrchis.rate[2] label "Покупка нал"
               ncrchis.rate[3] label "Продажа нал"
               ncrchis.rate[4] label "Покупка безнал"
               ncrchis.rate[5] label "Продажа безнал"
               ncrchis.rate[9] label "Размерн" format "z,zzz,zz9"
               t9 label "Тв./М"
               with title " КУРСЫ  ВАЛЮТ  (НАЦ.БАНК)" width 132.
            end.

            find first ofc where ofc.ofc = userid('bank').
            if ofc.mday[2] = 1 then put skip(14).
                               else put skip(1).
            output close.
          end.
     run menu-prt('rpt.img').
     pause before-hide.
     hide frame bbb.
*/
end.
else do:
    run menu-crc(dat1,dat2).
end.

