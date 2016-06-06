/* p-dev.p
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
        11/04/06 nataly добавила признак доходов-расходов
        30.05.06 marinav - возможность изменения названий и кода доходов-расходов
        18/04/08 marinav - увеличение формы
        04/05/08 marinav добавила описание фрейма
        08/08/2011 evseev - ввод адресов СП на рус. и каз. языках
*/

/* p-dev.p - Список департаментов

   08/07/02 добавлена синхронизация списка со справочником Профит-центров sproftcn - nadejda */

{mainhead.i}
def shared var vpoint like point.point.
def var vdep like ppoint.depart.
def var fl as int.
def var v-yes as logi no-undo format "Да/Нет" init no.
/*
DEFINE BUTTON b-ok LABEL "Сохранить ".
DEFINE BUTTON b-ext LABEL " Выход ".
*/
def frame fSP
		ppoint.info[5] label "Адрес" skip
		ppoint.info[6] label "Адрес (KZ)" skip
		ppoint.info[7] label "телефон" skip
        v-yes label "Признак закрытия СП"
 with 1 column CENTERED NO-LABELS OVERLAY.

{mult-t1.i
&start = " on help of ppoint.tel1 in frame ppoint do: run help-dep ('000').
                                       ppoint.tel1:screen-value = return-value.
                                       ppoint.tel1 = ppoint.tel1:screen-value.
                                   end.
"
&head = "ppoint"
&headkey = "depart"
&where = "ppoint.point = vpoint"
&index = ""
&type = "integer"
&datetype = "integer"
&formname = "ppoint"
&framename = "ppoint"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&start = " "
&viewframe = " "
&predisplay = " "
&display = "ppoint.depart ppoint.name ppoint.tel1"
&postdisplay = " "
&numprg = "prompt"
&preadd = " "
&postadd = " if ppoint.depart = 0 then do :
                Message ' Правильно введите код департамента '. pause.
                undo, retry.
             end.
  "
&preupdate = " "
&update = " ppoint.name ppoint.tel1 "
&newpostupdate = " update ppoint.name ppoint.tel1 with frame ppoint . ppoint.point = vpoint. run addprofit."
&predelete = " vdep = ppoint.depart.
               vpoint = ppoint.point.
               fl = 0.
               for each ofc :
                if ofc.regno = vdep * 1000 + vpoint then fl = 1.
               end.
               if fl = 1 then do :
          Message ' Сначала удалите всех офицеров данного департамента.' .
                 pause.
                 next outer.
               end.
               for each pglbal where pglbal.point = vpoint and
                   pglba.depart = vdep :
                 if ( pglba.dam - pglbal.cam ) <> 0 then do :
             Message ' Баланс <> 0. Сначала исправьте баланс. '.
                   pause.
                   next outer.
                 end.
               end.
               "
&postdelete = " for each pglbal where pglbal.point = vpoint and
                   pglba.depart = vdep :
                   delete pglbal.
                end.

 /*
                for each pglday where pglday.point = vpoint and
                   pglday.depart = vdep :
                   delete pglday.
                end.  */
"
&get = " "
&put = " "
&end = " hide message. "
&key-e = " if ppoint.info[8] = '1' then v-yes = true. else  v-yes = false.
update  ppoint.info[5]  ppoint.info[6]  ppoint.info[7] v-yes with frame fSP.
if v-yes then  ppoint.info[8] = '1'. else ppoint.info[8] = ''.
hide frame fSP. "
&message = " message 'E - добавление/изменение телефона и адреса СП'. "
}


procedure addprofit.
/*  добавить департамент в справочник Профит-центров sproftcn - 08/07/02   nadejda   */

             vdep = ppoint.depart.
             create codfr.
             codfr.codfr = 'sproftcn'.
/* коды СПФ в зависимости от филиала - Алматы A, Астана B, Уральск C */
             find sysc where sysc.sysc = "PCRKO" no-lock no-error.
             if not available sysc then prof-prefix = 'U'.
             else prof-prefix = trim(sysc.chval).
             codfr.code = prof-prefix + string(vdep, '99').
             codfr.name[1] = ppoint.name.
             codfr.papa = 'no'.
             codfr.level = 1.
             codfr.child = no.
             codfr.tree-node = codfr.codfr + chr(255) + codfr.code.
  /* --------------------------------------------------------------------------------- */
end procedure.

