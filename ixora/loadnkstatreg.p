/* loadnkstatreg.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/05/2012 evseev
 * BASES
        BANK COMM
 * CHANGES
        25.07.2012 evseev СЗ от 23.07.2012
*/

define input parameter p-loadfiles as char. /*загрузка указанного файла, - - не загружать файлы*/
define input parameter p-delref as char. /*перед загрузкой удалить из таблиз записи с указанным референсом*/

def var v-error    as logical no-undo.

run savelog ("nkstatreg", "Начало загрузки ..." ).

/*путь к папке теринала КЦМР*/
def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   run savelog ("nkstatreg", "Не найден параметр lbeks в sysc!" ).
   run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: В загрузке Статреестра", "ОШИБКА: В загрузке Статреестра", "1", "", "").
   return.
end.
v-term = sysc.chval.
/**/

def var v-files    as char no-undo.
def var v-str      as char no-undo.
def var i           as integer no-undo.
def var v-nkstatregin    as char no-undo.
def var v-exist1    as char no-undo.

v-error = false.


if trim(p-delref) <> "" then do:
   run savelog ("nkstatreg", "реф. " + p-delref + " Начало удаления" ).
   for each nkstatreg_det where nkstatreg_det.ref = p-delref exclusive-lock:
       delete nkstatreg_det.
   end.
   for each nkstatreg where nkstatreg.ref = p-delref exclusive-lock:
       delete nkstatreg.
   end.
   run savelog ("nkstatreg", "реф. " + p-delref + " Завершение удаления" ).
end.


if trim(p-loadfiles) <> "" then do:
        v-files = p-loadfiles.
        run savelog ("nkstatreg", v-files + " Загрузка из указанного файла" ).
end. else  do:
        /*поиск Статреестра на Терминале КЦМР*/
        v-files = ''.
        input through value(
           'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis "SR1" '
           + replace(v-term,'/','\\\\') + 'Out\\\\*.998').
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            if v-str <> '' then do:
                v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
                if v-files <> "" then v-files = v-files + "|".
                v-files = v-files + v-str.
            end.
        end.
        /*конец поиска*/

        /*проверка были ли загружены эти файлы */
        v-str = v-files.
        v-files = ''.
        do i = 1 to num-entries(v-str,"|"):
            find first nkstatreg where nkstatreg.fname = entry(i,v-str,"|") and nkstatreg.regdt = today no-lock no-error.
            if not avail nkstatreg then do:
                if v-files <> "" then v-files = v-files + "|".
                v-files = v-files + entry(i,v-str,"|").
            end. else do:
              run savelog ("nkstatreg", "Файл " + entry(i,v-str,"|") + " был загружен." ).
              v-error = true.
            end.
        end.
        /*конец проверки*/

        if v-files = '' then do:
           run savelog ("nkstatreg", "Нет файлов для загрузки." ).
           /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: В загрузке Статреестра", "ОШИБКА: В загрузке Статреестра", "1", "", "").*/
           return.
        end.

        /*поиск папки, если нет создать и выдать права 777, если есть, то очистить её*/
        input through value( "find /tmp/nkstatreg/; echo $?").
        repeat:
            import unformatted v-exist1.
        end.
        if v-exist1 <> "0" then do:
            unix silent value ("mkdir /tmp/nkstatreg/").
            unix silent value("chmod 777 /tmp/nkstatreg/").
        end.
        else unix silent value ("rm -f /tmp/nkstatreg/*.*").
        /*конец поиск папки*/

        /*поиск папки, если не найдена, создать и выдать права 777*/
        v-nkstatregin = "/data/import/nkstatreg/" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
        input through value( "find " + v-nkstatregin + ";echo $?").
        repeat:
            import unformatted v-exist1.
        end.
        if v-exist1 <> "0" then do:
            unix silent value ("mkdir " + v-nkstatregin).
            unix silent value("chmod 777 " + v-nkstatregin).
        end.
        /*конец поиск папки*/

        /*копирование файлов из папкиТерминала КЦМР в tmp*/
        do i = 1 to num-entries(v-files, "|"):
            v-str = ''.
            input through value('scp -pq Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/nkstatreg/' + entry(i, v-files, "|") + ' ;echo $?').
            import unformatted v-str.
            if v-str <> "0" then do:
                run savelog( "nkstatreg", "Ошибка копирования файлов Статреестра из терминала КЦМР! " + v-files).
                /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: В загрузке Статреестра", "ОШИБКА: В загрузке Статреестра", "1", "", "").*/
                return.
            end.
        end.
        /*конец копирования*/

        /*копирование файлов из tmp в архив*/
        unix silent value('cp /tmp/nkstatreg/*.998 ' + v-nkstatregin).
end.

if v-files <> "-" then do:
        def temp-table t-nkstatreg no-undo
            field num as int
            field str as char format "x(100)"
            index idx is primary num.

        def var v-txt like t-nkstatreg.str no-undo.

        def var v-count as int.
        def stream r-in.
        def var v-filename as char.



        def var v-ref as char no-undo.
        def var v-docdt as date no-undo.
        def var v-docnum as char no-undo.

        def var v-io      as   char no-undo.
        def var v-dtype   as   char no-undo.
        def var v-dttime  as   char no-undo.
        def var v-docref  as   char no-undo.
        def var v-sts     as   integer no-undo.
        def var v-err     as   char no-undo.

        do i = 1 to num-entries(v-files, "|"):
           empty temp-table t-nkstatreg.
           v-filename = entry(i, v-files, "|").

           /**/
           input through value( "find /tmp/nkstatreg/" + v-filename + ";echo $?").
           repeat:
               import unformatted v-exist1.
           end.
           if v-exist1 <> "0" then do:
              run savelog ("nkstatreg", v-filename + " файл не найден, переход на сл.файл.").
              v-error = true.
              next.
           end.
           /**/

           input stream r-in from value("/tmp/nkstatreg/" + v-filename).
           v-count = 0.
           repeat:
              v-count = v-count + 1.
              import stream r-in unformatted v-txt.
              if v-txt <> "" then do:
                 create t-nkstatreg.
                     assign t-nkstatreg.num = v-count
                            t-nkstatreg.str = v-txt.
              end.
           end.
           input stream r-in close.
           if v-count <= 1 then do:
              run savelog ("nkstatreg", v-filename + " файл пуст.").
              v-error = true.
              next.
           end.
           find first t-nkstatreg where t-nkstatreg.str begins ":20:" no-lock no-error.
           if avail t-nkstatreg then v-ref = entry(3, t-nkstatreg.str, ":"). else do:
              run savelog ("nkstatreg", v-filename + " не найден референс.").
              v-error = true.
              next.
           end.
           if trim(v-ref) = "" then do:
              run savelog ("nkstatreg", v-filename + " пустой референс.").
              v-error = true.
              next.
           end.
           find first nkstatreg where nkstatreg.ref = v-ref no-lock no-error.
           if avail nkstatreg then do:
              run savelog ("nkstatreg", v-filename + " референс " + v-ref + " уже имеется в БД!" ).
              v-error = true.
              next.
           end.

           v-str = "".
           find first t-nkstatreg where t-nkstatreg.str begins ":77E:" no-lock no-error.
           if avail t-nkstatreg then v-str = entry(3, t-nkstatreg.str, "/").
           v-str = trim(v-str).
           if v-str = "" then do:
              run savelog ("nkstatreg", v-filename + " нет даты.").
              v-error = true.
              next.
           end.
           if length(v-str) <> 6 then do:
              run savelog ("nkstatreg", v-filename + " не верный формат даты. [1]").
              v-error = true.
              next.
           end.
           v-docdt = ?.
           v-docdt = date(substr(v-str,5,2) + "/" + substr(v-str,3,2) + "/" + substr(v-str,1,2)) no-error.
           if v-docdt = ? then do:
              run savelog ("nkstatreg", v-filename + " не верный формат даты. [2]").
              v-error = true.
              next.
           end.

           v-str = "".
           find first t-nkstatreg where t-nkstatreg.str begins ":77E:" no-lock no-error.
           if avail t-nkstatreg then v-docnum = entry(4, t-nkstatreg.str, "/").

           create nkstatreg.
           assign
              nkstatreg.fname = v-filename
              nkstatreg.regdt = today
              nkstatreg.ref = v-ref
              nkstatreg.docdt = v-docdt
              nkstatreg.docnum = v-docnum.


           for each t-nkstatreg where t-nkstatreg.str matches "*//*".
              v-io     = "ошибка". v-io     = entry(3, t-nkstatreg.str, "/") no-error.
              v-dtype  = "ошибка". v-dtype  = entry(4, t-nkstatreg.str, "/") no-error.
              v-dttime = "ошибка". v-dttime = entry(5, t-nkstatreg.str, "/") no-error.
              v-docref = "ошибка". v-docref = entry(6, t-nkstatreg.str, "/") no-error.
              v-sts    = 0.        v-sts    = int(entry(7, t-nkstatreg.str, "/")) no-error.
              v-err    = "".       v-err    = entry(8, t-nkstatreg.str, "/") no-error.

              if v-io = "ошибка" or v-dtype  = "ошибка" or v-dttime = "ошибка" or v-docref = "ошибка" or v-sts = 0 then do:
                 run savelog ("nkstatreg", v-filename + " стр:" + string(t-nkstatreg.num) + " ошибка в строке!").
                 v-error = true.
              end.
              if trim(v-io) = "" or trim(v-dtype)  = "" or trim(v-dttime) = "" or trim(v-docref) = "" then do:
                 run savelog ("nkstatreg", v-filename + " стр:" + string(t-nkstatreg.num) + " ошибка в строке. пустая переменная!").
                 v-error = true.
              end.

              create nkstatreg_det.
              assign
                 nkstatreg_det.ref     = v-ref
                 nkstatreg_det.strnum  = t-nkstatreg.num
                 nkstatreg_det.io      = v-io
                 nkstatreg_det.dtype   = v-dtype
                 nkstatreg_det.dttime  = v-dttime
                 nkstatreg_det.docref  = v-docref
                 nkstatreg_det.sts     = v-sts
                 nkstatreg_det.err     = v-err.
           end.
        end.
end.
run savelog ("nkstatreg", "Загрузка завершена ..." ).

/*if v-error then
   run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: В загрузке Статреестра", "ОШИБКА: В загрузке Статреестра", "1", "", "").*/