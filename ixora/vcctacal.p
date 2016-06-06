/* vcctacal.p
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
*/

/* vccontrs.p Валютный контроль 
   Акцепт всех документов по контракту и данных самого контракта

   25.10.2002 nadejda создан
*/

{vc.i}

{global.i}
{nlvar.i}

def shared var s-contract like vccontrs.contract.
def var v-ans as logical init no.

message skip 
   "Будет произведено акцептование данных контракта" skip 
   "и ВСЕХ ДОКУМЕНТОВ по контракту !" skip(1) 
   "Вы уверены ?" skip(1) 
   view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice as logical.

if v-choice then do transaction on error undo, retry:
  find vccontrs where vccontrs.contract = s-contract no-lock no-error.

/* акцептуем все документы */
  for each vcps where vcps.contract = s-contract and vcps.cdt = ? exclusive-lock:
    vcps.cdt = g-today.
    vcps.cwho = g-ofc.
    /* записать в историю */
    run vc2hisps(vcps.ps, "Документ акцептован").
  end.
  for each vcrslc where vcrslc.contract = s-contract and vcrslc.cdt = ? exclusive-lock:
    vcrslc.cdt = g-today.
    vcrslc.cwho = g-ofc.
    /* записать в историю */
    run vc2hisrslc(vcrslc.rslc, "Документ акцептован").
  end.
  for each vcdocs where vcdocs.contract = s-contract and vcdocs.cdt = ? exclusive-lock:
    vcdocs.cdt = g-today.
    vcdocs.cwho = g-ofc.
    /* записать в историю */
    run vc2hisdocs(vcdocs.docs, "Документ акцептован").
  end.
  
  find current vccontrs exclusive-lock.
  vccontrs.cdt = g-today.
  vccontrs.cwho = g-ofc.
  find current vccontrs no-lock.
  /* записать в историю */
  run vc2hisct(vccontrs.contract, "Контракт акцептован").

  s-noedt = true.
  s-nodel = true.
  s-page = 1.
  run nlmenu.
end.
