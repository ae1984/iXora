/* menuperm.p
 * MODULE
        Администратор
 * DESCRIPTION
        Получить список пользователей и пакетов пункту меню (в Excel)
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
 * BASES
        bank
 * AUTHOR
        21.09.2006 sasco
 * CHANGES
*/


define variable v-fname as character initial "" format "x(8)" no-undo.
define variable v-des as character initial "" format "x(40)" no-undo.
define variable vans as logical init yes no-undo.
define variable i as integer no-undo.
define variable uvol as logical initial no format "2/1".

/* итоговая таблица */
define temp-table tmp no-undo
                field ofc like ofc.ofc
                field name like ofc.name
                field paket like ofc.ofc
                field pname like ofc.name
                index itmp is primary ofc paket.

/* временная таблица для сбора пакетодержателей чтобы таблицу ofc лишний раз не гонять */
define temp-table tmp-p no-undo
                field ofc like ofc.ofc
                field name like ofc.name
                field paket like ofc.ofc
                field pname like ofc.name
                index itmp is primary ofc paket.

/* общий цикл - запрашиваем код пункта меню пока не треснем */
repeat on endkey undo, return:
   update v-fname label "Код меню" help "Получение списка доступа к пункту меню" skip 
          v-des view-as text label "Описание"
          with row 2 centered side-labels frame getfnamefr.
   
   find first nmenu where nmenu.fname = v-fname no-lock no-error.
   if not avail nmenu 
      then message "Пункт меню " v-fname " отсутствует в АБПК Прагма!~nПовторите ввод..." view-as alert-box.
      else do:
          find nmdes where nmdes.fname = v-fname and nmdes.lang = "RR" no-lock no-error.
          if avail nmdes then do:
             v-des = nmdes.des.
             displ v-des with frame getfnamefr. 
             pause 0.
             update uvol label "Показать со статусом" skip(1)
                    " 1 - список будет из работающих" skip
                    " 2 - список будет из уволенных" skip
                    with centered row 7 side-labels frame getuvolfr.
             message "Сформировать отчет?" update vans.
          end.
      end.
   if vans then leave.
end. /* repeat */


/* получаем список всех пользователей пункта меню */
for each sec where sec.fname = v-fname no-lock:

    /* проверка на вшивость записей в ofc... */
    find ofc where ofc.ofc = sec.ofc no-lock no-error.
    if not avail ofc then next.

    /* критерии уволенности */
    find ofcblok where ofcblok.sts = "u" and ofcblok.ofc = ofc.ofc no-lock no-error.
    if avail ofcblok and not uvol then next.
    if not avail ofcblok and uvol then next.

    /* если у нас пакет доступа ... */
    if sec.ofc begins "p0" or sec.ofc = 'p77777' or sec.ofc = 'p55555' then do:
       create tmp-p.
       assign tmp-p.paket = ofc.ofc
              tmp-p.pname = ofc.name.
    end.
    /* если у нас голый пользователь ... */
    else do:
       create tmp.
       assign tmp.paket = "Без пакета"
              tmp.pname = ""
              tmp.ofc = ofc.ofc
              tmp.name = ofc.name.
    end.
end.

/* формирование итоговой таблицы - дополнение пакетов к пользователям... */
for each ofc no-lock:
    /* все пакеты офицера */
    do i = 1 to num-entries (ofc.expr[1]):
       /* поищем в нашем списке доступа пакетов к пункту ... */
       find tmp-p where tmp-p.paket = entry (i, ofc.expr[1]) no-error.
       /* если нашли - в отчет */
       if avail tmp-p then do:
          create tmp.
          buffer-copy tmp-p to tmp.
          assign tmp.ofc = ofc.ofc
                 tmp.name = ofc.name.
       end.
    end.
end.

output to fname.html.
{html-start.i "unformatted"}

put unformatted "<H2>Доступ к пункту меню <b>&laquo;<i>" v-des "</i>&raquo;</b>, код <b>" CAPS (v-fname) 
                "</b> предоставлен следующим пользователям: <br>" skip.

put unformatted "<table border=""1""><tr><td>Пакет доступа</td><td>Название пакета доступа</td><td>Учетная запись(логин)</td><td>ФИО</td></tr>" skip.
for each tmp:
    put unformatted "<tr>"
                    "<td>" tmp.paket "</td>"
                    "<td>" tmp.pname "</td>"
                    "<td>" tmp.ofc "</td>"
                    "<td>" tmp.name "</td>"
                    "</tr>" skip.
end.
put unformatted "</table>" skip.

{html-end.i "unformatted"}
output close.

unix silent cptwin fname.html excel.

