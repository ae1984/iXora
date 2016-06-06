/* vcdolgshis0.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Просмотр истории документа по долгам
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
        24/06/04 saltanat
 * CHANGES
        28.12.2010 aigul - Вывод данных в историю
*/

{vc.i}

def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def shared var s-contract like vccontrs.contract.
def var v-contrnum as char.

{vc-vhis.i
 &head = "vcdolgs"
 &headkey = "dolgs"
 &headhis = "vcdolgshis"
 &start = " "
 &frame = "vcdndlg"
 &predisplay = "
      find vccontrs where vccontrs.contract = s-contract no-lock no-error.
      if avail vcdolgs then run defvars.
      else do: v-dntypename = ''. end.
      if vccontrs.expimp = 'i' then v-contrnum = 'импорт, '.
      else v-contrnum = 'экспорт, '.
      v-contrnum = v-contrnum + trim(vccontrs.ctnum) + ' от ' + string(vccontrs.ctdate, '99/99/9999').
      "
 &header = "ДОКУМЕНТА"
 &displcif = "true"
 &display = " /*vcdolgs.dntype v-dntypename vcdolgs.rdt vcdolgs.rwho vcdolgs.cdt vcdolgs.cwho
              vcdolgs.pdt vcdolgs.pwho vcdolgs.dnnum vcdolgs.dnvn vcdolgs.dnpg vcdolgs.dopsv
              vcdolgs.info[1] label ' ' vcdolgs.info[2] label ' ' vcdolgs.info[3] label ' '*/
              vcdolgs.dntype v-dntypename vcdolgs.rdt  vcdolgs.rwho vcdolgs.cdt vcdolgs.cwho
              vcdolgs.dnnum vcdolgs.dndate vcdolgs.pdt
              vcdolgs.payret vcdolgs.sumpercent  vcdolgs.info[2] vcdolgs.pcrc vcdolgs.sum vcdolgs.cursdoc-con
              v-sumdoccon vcdolgs.info[4] vcdolgs.knp vcdolgs.origin vcdolgs.kod14 vcdolgs.info[1]
              "
}

procedure defvars.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdolgs.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
end.
