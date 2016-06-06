/* kfmcopy.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Создаем запись в фин.мониторинге
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
        30/03/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        29/04/2010 galina - берем электронные адреса для рассылки из справочника
        01/06/2010 galina - добавила kfm.i
        19/01/2012 evseev - добавил логирование
*/
{global.i}
def input parameter p-operId as int.
def input parameter p-operDoc as char.
def input parameter p-operType as char.

def input parameter p-jh as integer no-undo.

def var v-bname as char no-undo.
def var v-subj as char no-undo.
def var v-maillist as char no-undo.
def var i as integer no-undo.

{kfm.i}

run savelog( "kfmcopy", string(p-operId) + " " + p-operDoc + " " + p-operType + " " + string(p-jh)).

create kfmoper.
assign kfmoper.bank = s-ourbank
       kfmoper.operId = p-operId
       kfmoper.operDoc = p-operDoc
       kfmoper.sts = 0
       kfmoper.rwho = g-ofc
       kfmoper.rwhn = g-today
       kfmoper.operType = p-operType /* fm - фин. мониторинг, su - подозрительная */
       kfmoper.jh = p-jh
       kfmoper.rtim = time.

for each t-kfmoperh where t-kfmoperh.bank = s-ourbank and t-kfmoperh.operId = p-operId no-lock:
    create kfmoperh.
    buffer-copy t-kfmoperh except t-kfmoperh.showOrder t-kfmoperh.dataName t-kfmoperh.dataSpr t-kfmoperh.dataValueVis to kfmoperh.
end.
for each t-kfmprt where t-kfmprt.bank = s-ourbank and t-kfmprt.operId = p-operId exclusive-lock:
    create kfmprt.
    buffer-copy t-kfmprt to kfmprt.
end.
for each t-kfmprth where t-kfmprth.bank = s-ourbank and t-kfmprth.operId = p-operId exclusive-lock:
    create kfmprth.
    buffer-copy t-kfmprth except t-kfmprth.showOrder t-kfmprth.dataName t-kfmprth.dataSpr t-kfmprth.dataValueVis to kfmprth.
end.

/*отправляем сообщение комплайнс менеджеру*/
v-bname = ''.
v-subj = ''.
find first txb where txb.consolid and txb.bank = s-ourbank no-lock no-error.
if avail txb then v-bname = txb.info.
if p-operType = 'fm' then v-subj = "Проведена операция, подлежащая фин.мониторингу".
else  v-subj = "Создана подозрительная операция".

v-maillist = ''.
find first sysc where sysc.sysc = "kfmmail" no-lock no-error.
if avail sysc and trim(sysc.chval) <> '' then do:
    do i = 1 to num-entries(sysc.chval):
        if trim(entry(i,sysc.chval)) <> '' then do:
            if v-maillist <> '' then v-maillist = v-maillist + ','.
            v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@metrocombank.kz".
        end.
    end. /* do i = 1 */
    if v-maillist <> '' then do:
        /*"id00532@metrocombank.kz;id00243@metrocombank.kz"*/
        run mail(v-maillist ,"METROCOMBANK <abpk@metrocombank.kz>", v-subj,"Филиал: " + v-bname + "\n" + "Номер формы ФМ-1: " + string(p-operId) + "\n " + "Номер документа в iXora: " + p-operDoc, "", "","").
    end.
end.




