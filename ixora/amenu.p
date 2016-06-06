/* amenu.p
 * MODULE
        Главное меню
 * DESCRIPTION
        Проверка дополнительных условий на вход в базу
 * RUN
        
 * CALLER
        pmenu.p
 * SCRIPT
        
 * INHERIT
        nmenu.p
 * MENU
        первичный вход
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07.03.2004 nadejda - проверка на временную блокировку пользователя
        20.07.2004 suchkov - проверка признака увольнения пользователя
*/

def var dtout as date.
find last cls no-lock no-error.
dtout = if available cls then cls.cls + 1 else today.
find first sysc where sysc.sysc = "SUPUSR" no-lock no-error. 
if ( (avail sysc) and (lookup(userid("bank"), sysc.chval) = 0)
   and sysc.loval ) or not avail sysc then do:
      display  
      " Внимание!!! " skip 
      " Доступ к Системе закрыт! " skip 
      " Проводятся технологические работы! " skip
      " Операционный день" dtout no-label "г. "
      with centered row 10. 
      pause 2. 
      quit. 
end. 

/* 07.03.2004 nadejda - проверить, не блокирован ли пользователь */
find last ofcblok where ofcblok.ofc = userid("bank") and ofcblok.sts = "b" and 
                        ofcblok.fdt <= today and ofcblok.tdt >= today no-lock no-error.
if avail ofcblok then do:
    message skip
    " Доступ к Системе для пользователя " userid("bank") " ЗАБЛОКИРОВАН! " skip(1) 
    " Обратитесь к администраторам АБПК. " skip(1)
     view-as alert-box button ok title "   В Н И М А Н И Е  !  ". 
    quit. 
end.

/* 20.07.2004 - suchkov - проверить, не уволен ли пользователь */
find last ofcblok where ofcblok.ofc = userid("bank") and ofcblok.sts = "u" and 
                        ofcblok.tdt <= today no-lock no-error.
if avail ofcblok then do:
    message skip
    " Доступ закрыт! " skip(1)
    " Обратитесь к администраторам АБПК. " skip(1)
     view-as alert-box button ok title "   В Н И М А Н И Е  !  ". 
    quit. 
end.

run nmenu. 


