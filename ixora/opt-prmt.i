/* opt-prmt.i
 * MODULE
        Главное меню
 * DESCRIPTION
        Функции для проверки прав пользователя на пункты верхнего меню
 * RUN
        sisn.i, sixn.i, vc-sixn.i, vc-sisn.i, vc-alldoc.i
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        01.10.2002 nadejda
 * CHANGES
        22.06.2004 nadejda - добавила поиск настройки на разрешение на запуск пункта верхнего меню в 1.2
        23.08.2004 sasco   - Обработка пакетов доступа
*/


function chkrights returns logical (p-proc as char).
  def var v-isavail as logical.
  def var vofcpak as char.
  define variable vi as int.
  run getpakets (g-ofc).
  vofcpak = return-value.

  find optitsec where optitsec.proc = p-proc and 
     optitsec.ofcs <> "" no-lock no-error .
    /* v-isavail = not (avail optitsec and (lookup(g-ofc, optitsec.ofcs) = 0)). */
     if not avail optitsec then v-isavail = yes.
     else do: do vi = 1 to num-entries (optitsec.ofcs): if trim(entry(vi,optitsec.ofcs)) <> "" and 
         lookup (entry(vi,optitsec.ofcs), vofcpak) > 0 then v-isavail = yes. end. end.

  return v-isavail.
end.

function get-des returns char (p-opt as char, p-proc as char, i as integer).
  def var s as char.
  def buffer b-optitem for optitem.
  find first b-optitem where b-optitem.optmenu = p-opt and b-optitem.proc = p-proc no-lock no-error.
  if not avail b-optitem then return "".

  s = trim(b-optitem.des).
  if s = "" or num-entries(s) < i then return "".

  s = trim(entry(i, s)).
  return s.
end.

function chkproc-ro returns char (p-opt as char, p-proc as char).
  /* в первом элементе списка - процедура только для чтения, аналогичная процедуре изменения */
  return get-des (p-opt, p-proc, 1).
end.

/* 22.06.2004 nadejda */
function chkavail_run returns char (p-opt as char, p-proc as char).
  /* во втором элементе списка - разрешение на запуск пункта верхнего меню в 1.2 */
  return get-des (p-opt, p-proc, 2).
end.
