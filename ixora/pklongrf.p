/* pklongrf.p
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
   Формирование графика погашения кредита и выдача его в Word
   Выдача приложений

   10.02.2003 marinav
   17.11.2003 marinav опись документов
   25.11.2003 marinav убрала опись документов
   05.12.2003 nadejda - меняем статус на 60, только если график существует
   18.12.2003 marinav - запуск pkaftertrx , только если статус меньше 99
   31.03.2004 nadejda - убрано условие на совпадние последней даты графика с датой погашения кредита
   23.04.2004 nadejda - выход, если не найден график
   24/06/2005 madiyar - убрал заявление на перевод денег для БД
   27/06/2005 madiyar - убрать заявление на перевод денег надо было только в Алматы
   27/07/2005 madiyar - добавил образец подписи - пока только для БД
   07.09.2005 marinav - при вызове pksigns - передается логич параметр - печатать или не печатать адрес
   23/09/2005 madiyar - добавил транзакционный блок - для решения проблемы появления кредитов без графиков
   12/10/2005 madiyar - убрал заявление на перевод денег для БД (теперь точно для всех филиалов)
   13/10/2005 madiyar - заявление убрали слишком рано - новые тарифы еще не утверждены, вернул обратно
   19/10/2005 madiyar - тарифы утвердили, опять убрал заявление на перевод денег для БД (надеюсь, в последний раз)
   28/06/2006 madiyar - проверка наличия графика в конце
   19/02/2007 madiyar - изменил шаренную таблицу
   23/02/2007 madiyar - исправил ошибку - при повторной распечатке графика не заполнялась временная таблица
   13/03/2007 madiyar - убрал все сопутствующие графику документу (будут формировать в пункте ВсеДок)
   24/04/2007 madiyar - веб-анкеты
   09/09/2009 madiyar - добавил поле com в шаренную таблицу
   20/12/2009 galina - добавила параметр p-graf для выбора предварительного формирования графика или окончательного формирования
   30/12/2009 galina - не меняем статус анкеты при повторной распечатке графика
   12/01/2010 galina - перенесла pkaftertrx- в pkcifnew
*/


{global.i}
{pk.i}
{pk-sysc.i}

/*
s-credtype = "1".
s-pkankln = 35.
*/
def input parameter p-graf as logical.

def var v-ans as logical no-undo.
def var v-sts as logical no-undo init true.
def var i as integer no-undo.
/*
def var v-recount as logical init false.
def var AtlSum like lnsch.stval.
*/
def new shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field com    as logi init no
    index idx is primary stdat.


if s-pkankln = 0 then return.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
s-lon = pkanketa.lon.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

if pkanketa.sts < "50" and p-graf then do:
  if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Не открыт ссудный счет! Печать графиков невозможна!").
  else message skip " Не открыт ссудный счет ! Печать графиков невозможна !" skip(1) view-as alert-box buttons ok .
  return.
end.

/* если уже графики сформированы то просто распечатать */
if pkanketa.sts >= "60" and p-graf then do:
    if v-inet then return.
    else do:
        v-ans = false.
        message skip " Документы уже сформированы !~n Распечатать снова?" skip(1)
        view-as alert-box buttons yes-no title "" update v-ans.
        if not v-ans then return.
        v-sts = false.
    end.
end.

/*
def new shared temp-table  wrk
    field nn     as integer
    field days   as integer
    field stdat  like lnsch.stdat
    field begs   like lnsch.stval
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field ends   like lnsch.stval.
*/

if s-lon <> '' then find lon where lon.lon = pkanketa.lon no-lock.
    
if (s-lon <> '' and (not v-sts or not p-graf)) then do:
   find first lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock no-error.
   if not available lnsch then do:
      if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Произошла ошибка при формировании графика!").
      else message " Произошла ошибка при формировании графика! " view-as alert-box buttons ok.
      return.
   end.
       
   for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock:
      create wrk.
             wrk.stdat = lnsch.stdat.
             wrk.od = lnsch.stval.
             wrk.com = yes.
   end.
        
   for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock:
      find first wrk where wrk.stdat = lnsci.idat no-lock no-error.
      if not avail wrk then do:
        create wrk.
               wrk.stdat = lnsci.idat.
      end.
      wrk.proc = lnsci.iv-sc.
   end.
end.
find first wrk no-lock no-error.
if not avail wrk then run VALUE("pkgrf" + string(get-pksysc-int ("pkplan"))).
   

i = 1.
for each wrk:
    wrk.nn = i.
    i = i + 1.
end.

if p-graf then do:
    for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0:
        delete lnsch.
    end.
    for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0:
        delete lnsci.
    end.

    for each wrk no-lock:
      find first lnsch where lnsch.lnn = s-lon and lnsch.stdat = wrk.stdat and lnsch.f0 > 0 no-lock no-error.
      if not avail lnsch then do: 
        create lnsch.
        lnsch.stdat = wrk.stdat.
        lnsch.stval = wrk.od.
        lnsch.lnn = s-lon.
        lnsch.f0 = wrk.nn.
        
      end.  
      find first lnsci where lnsci.lni = s-lon and lnsci.idat = wrk.stdat and lnsci.f0 > 0 no-lock no-error.
      if not avail lnsci then do: 
        create lnsci.
        lnsci.idat = wrk.stdat.
        lnsci.iv-sc = wrk.proc.
        lnsci.lni = s-lon.
        lnsci.f0 = wrk.nn.
      end.
    end.
    
    run lnsch-ren(s-lon).
    release lnsch.
    
    run lnsci-ren(s-lon).
    release lnsci.

   find first lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock no-error.
   if not available lnsch then do:
      if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Произошла ошибка при формировании графика!").
      else message " Произошла ошибка при формировании графика! " view-as alert-box buttons ok.
      return.
   end.
end.

/* печать графика */
/*
run pkprtgraf (v-recount).
*/

run value("pkprtgrf-" + s-credtype).

if v-sts and p-graf then do transaction:
  /* 05.12.2003 nadejda - меняем статус только если график существует */
  find lon where lon.lon = s-lon no-lock no-error.
  find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                         and lnsch.f0 > -1 /* 31.03.2004 nadejda - and lnsch.stdat = lon.duedt */ no-lock no-error.
  if available lnsch then do:
    find current pkanketa exclusive-lock.
    pkanketa.sts = "60".
    find current pkanketa no-lock.
  end.
  else do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Ошибка! Графики не сформированы!").
    else message " Ошибка! Графики не сформированы! " view-as alert-box buttons ok.
    return.
  end.
end.
release pkanketa.

/*
Печать приложения к кредитному досье
run pkpril.

заявление на перевод денег на счет магазина
if s-credtype <> '6' then run pkprtzayav.

run pksigns(yes).

заявление в бухгалтерию
run pkzaybuh.
*/

/*do transaction:
    if v-sts and p-graf then do:
        /* некоторые действия, необходимые после полной выдачи - для разных видов кредитов */
        run value ("pkaftertrx-" + s-credtype).
    end.
end.*/ /* transaction */

if v-sts and p-graf then do:
    find lon where lon.lon = s-lon no-lock no-error.
    find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1 no-lock no-error.
    if not available lnsch then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Ошибка! График отсутствует!").
        else message " Ошибка! График отсутствует! " view-as alert-box buttons ok.
        return.
    end.
end.

/*
message skip " Документы открыты в новом окне!" skip(1)
  " Распечатайте нужное количество экземпляров!"
  skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
*/
