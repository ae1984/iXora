/*LCMT_ps.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        импорт свифт-сообщений
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
        27/12/2010 id00810
 * BASES
        BANK COMM
 * CHANGES
        03/02/2011 id00810 - убрала дату при поиске загруженных ранее файлов в LCswt
        04/02/2011 id00810 - создание подкаталога ./lcmt, чтоб не копировать лишние файлы
        10/02/2011 id00810 - МТ700, поле 40А, вид продукта
        11/01/2011 id00810 - standby - проверить еще поле 47А
        13/03/2012 id00810 - изменилась структура параметра lcmail для рассылки сообщений
        29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
        12.07.2012 Lyubov  - для мт 760 референс не укзываем
        13.08.2012 Lyubov  - добвила отправку писем для входящих МТ999

*/

def var v-files0    as char no-undo.
def var v-files     as char no-undo.
def var i           as int  no-undo.
def var v-str       as char no-undo.
def var v-lcmt      as char no-undo.
def var v-lcmth     as char no-undo.
def var v-exist1    as char no-undo.
def var v-filename  as char no-undo.
def var v-mt        as char no-undo.
def var j           as int  no-undo.
def var jj          as int  no-undo.
def var start       as log  no-undo.
def var fin         as log  no-undo.
def var ii          as int  no-undo.
def var ost         as char no-undo.
def var v-ref       as char no-undo.
def var v-refa      as char no-undo.
def var v-maillist  as char no-undo extent 2.
def var v-mailmessage as char no-undo.
def var v-formcred  as char no-undo.
def temp-table t-swt no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

def var v-txt       like t-swt.str no-undo.
def var v-tsnum     as int  no-undo.
def var v-mes       as char no-undo.
def var k           as int  no-undo.
def var v-sp        as char no-undo.
def stream r-in.

{global.i}

/* сообщение */
find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
if avail bookcod then do:
   do k = 1 to num-entries(bookcod.name,','):
      v-sp = entry(k,bookcod.name,',').
      do i = 1 to num-entries(v-sp):
         if trim(entry(i,v-sp)) <> '' then do:
            if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
            v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)).
         end.
      end.
   end.
end.

v-files0 = ''.
input through value( 'grep  -Elis "\{2:O7.." /swift/out/*.txt').

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"/"),v-str,"/").
        if v-files0 <> "" then v-files0 = v-files0 + "|".
        v-files0 = v-files0 + v-str.
    end.
end.
if v-files0 = '' then return.
run savelog( "lcmt", "LCMT_ps: v-files0 = " + v-files0).

v-files = ''.
do i = 1 to num-entries(v-files0,"|"):
    find first LCswt where /*LCswt.rdt = g-today and*/ LCswt.fname1 = entry(i,v-files0,"|") no-lock no-error.
    if not avail LCswt then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i,v-files0,"|").
    end.
end.
if v-files = '' then return.
run savelog( "lcmt", "LCMT_ps: v-files = " + v-files).

v-lcmt = "/data/import/lcmt/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-lcmt + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-lcmt).
    unix silent value("chmod 777 " + v-lcmt).
end.

v-lcmth = "./lcmt/" .
input through value( "find " + v-lcmth + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-lcmth).
end.

do i = 1 to num-entries(v-files, "|"):
    v-str = ''.
    input through value('cp /swift/out/'  + entry(i, v-files, "|") + ' ' + v-lcmth + ' ;echo $?').
    import unformatted v-str.

    if v-str <> "0" then do:
        run savelog( "lcmt", "LCMT_ps: Ошибка копирования swift-файлов!").
        return.
    end.
end.
unix silent value('cp ' + v-lcmth + '*.txt ' + v-lcmt).

do i = 1 to num-entries(v-files, "|"):
   do transaction:
        v-filename = entry(i, v-files, "|").
        unix silent value('echo "" >> ' + v-lcmth + v-filename).

        empty temp-table t-swt.
        assign
            v-tsnum = 0
            v-str   = ""
            start   = no
            fin     = no
            j       = 0.
        input stream r-in from value(v-lcmth + v-filename).
        repeat:
            import stream r-in unformatted v-txt.

            if v-txt ne "" then do:
              if index(v-txt,chr(1)) = 1 and index(v-txt,"\{2:O7") > 0  then do:
                   /* начало сообщения */
                   assign j = j + 1 start = yes fin = no v-tsnum = 1 v-mt = substr(v-txt,index(v-txt,'\{2:O7') + 3,4) v-refa = ''.
                   empty temp-table t-swt.
                 /* message '1' j start. pause.*/
               end.
               if start then do:
                  if index(v-txt,chr(3)) > 0 then do:
                    /* конец сообщения */
                      assign start = no fin = yes
                            ii = index(v-txt,chr(3))
                            ost = trim(substr(v-txt,ii + 1))
                            v-txt = substr(v-txt,1,ii).
                       /* message 'fin' fin. pause.*/
                   end.
                   create t-swt.
                   assign t-swt.num = v-tsnum
                          t-swt.str = v-txt.
                   v-tsnum = v-tsnum + 1.
                   if fin then do:
                      output to value(v-lcmt + entry(1,v-filename,'.')  + '_' + string(j) + '.' + entry(2,v-filename,'.')).
                      for each t-swt no-lock.
                          put unform t-swt.str skip.
                      end.
                      output close.
                      v-mes = entry(1,v-filename,'.')  + '_' + string(j) + '.' + entry(2,v-filename,'.').
                      run savelog( "lcmt", "LCMT_ps: " + v-mes).

                      find first t-swt where t-swt.str begins ":20:" no-lock no-error.
                      if avail t-swt then do:
                        v-ref = trim(entry(3, t-swt.str, ":")).
                        find first LCswt where LCswt.fname2 = entry(1,v-filename,'.')  + '_' + string(j) + '.' + entry(2,v-filename,'.') no-lock no-error.
                        if not avail LCswt then do:
                            create LCswt.
                            assign LCswt.ref = v-ref
                                    LCswt.mt  = v-mt
                                    LCswt.rdt = g-today
                                    LCswt.sts = 'new'
                                    LCswt.fname1 = v-filename
                                    LCswt.fname2 = entry(1,v-filename,'.')  + '_' + string(j) + '.' + entry(2,v-filename,'.').
                            find first t-swt where t-swt.str begins ":21:" no-lock no-error.
                            if avail t-swt then do:
                                v-refa = trim(entry(3, t-swt.str, ":")).
                                find first LC where LC.LC = v-refa no-lock no-error.
                                if avail LC then assign LCswt.LC = LC.LC
                                                        LCswt.LCtype = LC.LCtype.
                            end.
                            find first t-swt where t-swt.str begins ":40A:" no-lock no-error.
                            if not avail t-swt then find first t-swt where t-swt.str begins ":40B:" no-lock no-error.
                            if avail t-swt then do:
                                v-formcred = trim(entry(3, t-swt.str, ":")).
                                if index(v-formcred,'standby') > 0 then LCswt.LC = 'EXSBLC'.
                                else do:
                                    find first t-swt where t-swt.str begins ":47A:" no-lock no-error.
                                    if avail t-swt then do:
                                        v-formcred = trim(entry(3, t-swt.str, ":")).
                                        if index(v-formcred,'standby') > 0 then LCswt.LC = 'EXSBLC'.
                                        else LCswt.LC = 'EXLC'.
                                    end.
                                    else LCswt.LC = 'EXLC'.
                                end.
                            end.
                            find first t-swt where t-swt.str begins "MT:760" or t-swt.str begins "MT:799" or t-swt.str begins "MT:999" no-lock no-error.
                            if avail t-swt then LCswt.qswift = substr(t-swt.str,4,3).
                            if v-maillist[1] <> '' then do:
                                v-mailmessage = 'Incoming ' + v-mt + '~n~n'.
                                if v-refa ne '' and v-mt <> 'O760' then v-mailmessage = v-mailmessage + 'Related reference ' + v-refa + '~n~n'.
                                if LCswt.qswift ne '' then v-mailmessage = v-mailmessage + 'Quote ' + LCswt.qswift + '~n~n'.
                                run mail(v-maillist[1], "FORTEBANK <abpk@fortebank.com>", "Incoming SWIFT", v-mailmessage, "", "", "").
                                if v-maillist[2] <> '' then run mail(v-maillist[2], "FORTEBANK <abpk@fortebank.com>", "Incoming SWIFT", v-mailmessage, "", "", "").
                            end.
                        end.
                      end.
                      empty temp-table t-swt.
                      /*message ost index(ost,'\{2:O7') > 0. pause.*/
                      if ost ne '' and index(ost,'\{2:O7') > 0  then do:
                      /* строка продолжается, начало нового сообщения */
                         assign j = j + 1 start = yes fin = no v-tsnum = 1 v-mt = substr(ost,index(ost,'\{2:O7') + 3,4) v-refa = ''.
                         /*message j start. pause.*/
                         create t-swt.
                         assign t-swt.num = v-tsnum
                                t-swt.str = ost.
                         v-tsnum = v-tsnum + 1.
                         ost = ''.
                      end.
                   end.
               end.
               if index(v-txt,chr(3)) > 0 and not start then do:
               /* конец сообщения (не O760, не O799) */
                  assign ii = index(v-txt,chr(3))
                        ost = trim(substr(v-txt,ii + 1))
                        v-txt = trim(substr(v-txt,ii + 1)).
                  if index(v-txt,chr(1)) > 0 and index(v-txt,'\{2:O7') > 0  then do:
                  /* строка продолжается, начало нового сообщения */
                     assign j = j + 1 start = yes fin = no v-tsnum = 1 v-mt = substr(v-txt,index(v-txt,'\{2:O7') + 3,4).
                     empty temp-table t-swt.
                    /* message '2' j start v-mt. pause.*/
                     create t-swt.
                     assign t-swt.num = v-tsnum
                            t-swt.str = v-txt.
                     v-tsnum = v-tsnum + 1.
                  end.
               end.
            end.
        end. /* repeat */
        input stream r-in close.
        unix silent rm -f value(v-lcmth + v-filename).

    end. /* transaction */
end. /* do */
