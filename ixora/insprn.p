/* insprn.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Вывод РПРО для распечатки
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
        28/01/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        27.08.2012 evseev - иин/бин
*/


def input parameter p-ref as char.
def var v-dt1 as char no-undo.
def var v-num1 as char no-undo.
def var v-bname as char no-undo.
def var v-brnn as char no-undo.
def var v-binf as char no-undo.
def var v-dt2 as char no-undo.
def var v-num2 as char no-undo.
def var v-nkname as char no-undo.
def var v-nkinfo as char no-undo.
def var v-reas as char no-undo.
def var v-clname as char no-undo.
def var v-clinfo as char no-undo.
def var v-cladr as char no-undo.
def var v-clacc as char no-undo.
def var v-bin  as char no-undo.
def var v-month as char init ["января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря"].
def var v-ofile as char no-undo.
def var v-ifile as char no-undo.
def var v-str  as char no-undo.
def var i as integer no-undo.
def stream v-out.
def stream r-in.


find first insin where insin.ref = p-ref no-lock no-error.
if not avail insin then return.

v-dt1 = '"' + string(day(insin.dtr),'99') + '" ' + entry(month(insin.dtr),v-month) + " " + string(year(insin.dtr),'9999') + " г.".
v-num1 = insin.numr.
find first txb where txb.bank = insin.bank no-lock no-error.

if connected ("txb") then disconnect "txb".
find first txb where txb.bank = insin.bank no-lock no-error.
if avail txb then do:
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
    run insinf(insin.clrnn,output v-bname, output v-brnn, output v-binf, output v-cladr, output v-bin).
    if connected ("txb") then disconnect "txb".
end.

v-bname = v-bname + ' (' + txb.mfo + ') '.
v-binf = v-bin + ', ' + v-binf.

v-dt2 = '"' + string(day(insin.dt),'99') + '" ' + entry(month(insin.dt),v-month) + " " + string(year(insin.dt),'9999') + " года".
v-num2 = insin.num.

find first taxnk where taxnk.bin = insin.nkbin no-lock no-error.
if avail taxnk then v-nkname = taxnk.name.
v-nkinfo = insin.nkbin.

v-reas = ''.
if insin.reas = '01' then v-reas = 'непредставление налогоплательщиком (налоговым агентом) налоговой отчетности'.
if insin.reas = '02' then v-reas = 'непредставление налогоплательщиком налогового заявления о постановке на регистрационный учет по налогу на добавленную стоимость'.
if insin.reas = '03' then v-reas = 'непогашение налоговой задолженности'.
if insin.reas = '04' then v-reas = 'недопуск должностных лиц органа налоговой службы к налоговой проверке и обследованию объектов налогообложения и (или) объектов, связанных с налогообложением, кроме случаев нарушения ими установленного Налоговым кодексом порядка проведения налоговой проверки'.
if insin.reas = '05' then v-reas = 'возврат почтовой или иной организацией связи направленного уведомления в связи с отсутствием налогоплательщика (налогового агента) по месту нахождения'.
if insin.reas = '06' then v-reas = 'установление факта отсутствия налогоплательщика (налогового агента) по месту нахождения на основании акта налогового обследования'.
if insin.reas = '07' then v-reas = 'неисполнение уведомления об устранении нарушений, выявленных по результатам камерального контроля'.

v-clname = insin.clname.
v-clinfo = "ИИН/БИН " + insin.clbin.

v-clacc = ''.
do i = 1 to num-entries(insin.iik):
  if v-clacc <> '' then v-clacc = v-clacc + ', '.
  v-clacc = v-clacc + entry(i,insin.iik).
end.

if insin.type = 'AC' then v-ifile = "/data/docs/insprn1.htm". /*Налог*/
if insin.type = 'ACP'  then v-ifile = "/data/docs/insprn2.htm". /*ОПВ*/
if insin.type = 'ASD'  then v-ifile = "/data/docs/insprn3.htm". /*СО*/
v-ofile = "ins.htm".

output stream v-out to value(v-ofile).
run upd_field.

unix silent value("cptwin " + v-ofile + " iexplore").


procedure upd_field.

input from value(v-ifile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*v-dt1*" then do:
            v-str = replace (v-str, "v-dt1", v-dt1).
            next.
        end.
        if v-str matches "*v-num1*" then do:
            v-str = replace (v-str, "v-num1", v-num1).
            next.
        end.
        if v-str matches "*v-bname*" then do:
            v-str = replace (v-str, "v-bname", v-bname).
            next.
        end.
        if v-str matches "*v-binf*" then do:
            v-str = replace (v-str, "v-binf", v-binf).
            next.
        end.
        if v-str matches "*v-dt2*" then do:
            v-str = replace (v-str, "v-dt2", v-dt2).
            next.
        end.
        if v-str matches "*v-num2*" then do:
            v-str = replace (v-str, "v-num2", v-num2).
            next.
        end.
        if v-str matches "*v-nkname*" then do:
            v-str = replace (v-str, "v-nkname", v-nkname).
            next.
        end.
        if v-str matches "*v-nkinfo*" then do:
            v-str = replace (v-str, "v-nkinfo", v-nkinfo).
            next.
        end.
        if v-str matches "*v-reas*" then do:
            v-str = replace (v-str, "v-reas", v-reas).
            next.
        end.
        if v-str matches "*v-clname*" then do:
            v-str = replace (v-str, "v-clname", v-clname).
            next.
        end.
        if v-str matches "*v-clinfo*" then do:
            v-str = replace (v-str, "v-clinfo", v-clinfo).
            next.
        end.
        if v-str matches "*v-cladr*" then do:
            v-str = replace (v-str, "v-cladr", v-cladr).
            next.
        end.
        if v-str matches "*v-clacc*" then do:
            v-str = replace (v-str, "v-clacc", v-clacc).
            next.
        end.


        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.

end.