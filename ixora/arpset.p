/* arpset.p
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
        15/04/2009 galina - изменения для генерации 20-тизначного счета
        16/04/2009 galina - вернула предыдущую версию
        17/04/2009 galina - выбор генерации 20-ти или 9-ти значного счета

*/

def var v-proc as widget-handle .
def new shared var s-gl like gl.gl.
def new shared var s-val like crc.crc.
def new shared var s-secek as char.
def new shared var s-length as logical init false format "да/нет".

DEFINE SUB-MENU wor
      MENU-ITEM arcr     LABEL "Создать"
      MENU-ITEM ared     LABEL "Редакт."
      MENU-ITEM arvw     LABEL "Просмотр".
      MENU-ITEM arsr     LABEL "Поиск по примечанию"    
      MENU-ITEM arcl     LABEL "Закрыть".

DEFINE SUB-MENU quitar
      MENU-ITEM arq  LABEL "Выход".

DEFINE SUB-MENU subcod
      MENU-ITEM subcod  LABEL "Признаки"
      MENU-ITEM balance LABEL "Остатки".

DEFINE MENU mbar     MENUBAR
      SUB-MENU wor   LABEL "Документ"
      SUB-MENU subcod  LABEL "Признаки"
      SUB-MENU quitar  LABEL "Выход".

ON CHOOSE OF MENU-ITEM arsr
do:
   run qp-arp. 
end.

ON CHOOSE OF MENU-ITEM arcr
     do :
         if  valid-handle(v-proc) then do on error undo, return :
           form 
            "СчГлКн : " s-gl "ВАЛЮТА : " s-val skip
            "Сгенерировать 20-значный счет? " s-length skip
            "Сектор экономики : " s-secek             
           with row 5 frame garp centered no-label.
           display s-length with frame garp.
           on help of s-secek in frame garp do:
              run h-codfr('secek',output s-secek).
              display s-secek with frame garp.
           end.
           do on error undo, retry :
            update s-gl  with frame garp.
            find gl where gl.gl = s-gl no-lock no-error.
            if not avail gl or ( avail gl and gl.sub ne "arp") 
            then do :
               Message "Введите верно счет главной киги". pause.
               undo,retry.
            end.   
           end.
           update s-val validate (can-find (crc where crc.crc = s-val),
                 "Введите верно код валюты")  with frame garp.
           update s-length with frame garp.                    
           if s-length then do:
              update s-secek validate (can-find (codfr where codfr.codfr = 'secek' and codfr.code = s-secek),
                 "Введите верно сектор экономики")  with frame garp.  
           end.      

           run n-arp in v-proc .
           run ed-arp in v-proc.
         end.
     end.
ON CHOOSE OF MENU-ITEM ared
     do :
      if valid-handle(v-proc) then 
        run ed-arp in v-proc . 
     end.

ON CHOOSE OF MENU-ITEM arvw
     do :
       if valid-handle(v-proc) then
       run q-arp in v-proc . 
     end.
ON CHOOSE OF MENU-ITEM subcod
    do :                               
       if valid-handle(v-proc) then     
       run subc in v-proc . 
    end.

ON CHOOSE OF MENU-ITEM balance
    do :
        if valid-handle(v-proc) then
        run ball in v-proc .
    end.
                      


ON CHOOSE OF MENU-ITEM arcl
     do:
       if valid-handle(v-proc) then do:
        apply "close" to v-proc.
       end.
     end.

if not valid-handle(v-proc) then do:
     run arpst  persistent set v-proc.
end.

ASSIGN CURRENT-WINDOW:MENUBAR = MENU mbar:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM arq .
    if valid-handle(v-proc) then do:
              apply "close" to v-proc.
    end.  
                     
if avail arp then release arp . 
    
