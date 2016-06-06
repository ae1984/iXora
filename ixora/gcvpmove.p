/* gcvpmove.p
 * MODULE
        Закрытие месяца
 * DESCRIPTION
        Перенос файлв ГЦВП в архив
 * RUN
        dayclose
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        03.08.05 marinav 
 * CHANGES
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/

 */

{global.i}

unix silent value ("if [ ! -d /data/import/gcvp/" + string(year(g-today)) + " ]; then mkdir /data/import/gcvp/" +
 string(year(g-today)) + "; chmod a+rx /data/import/gcvp/" + string(year(g-today)) + "; fi").

unix silent value ("if [ ! -d /data/import/gcvp/" + string(year(g-today)) + "/" + string(month(g-today),'99') + " ]; then mkdir /data/import/gcvp/" +
 string(year(g-today)) + "/" + string(month(g-today),'99') + "; chmod a+rx /data/import/gcvp/" + string(year(g-today)) + "/" +
 string(month(g-today),'99') + "; fi").
 
input through value("mv /data/import/gcvp/*  /data/import/gcvp/" + string(year(g-today)) +  "/" + string(month(g-today),'99') + "/" ).
input through value("mv /data/import/gcvp/gcvp*  /data/import/gcvp/" + string(year(g-today)) +  "/" + string(month(g-today),'99') + "/" ).
 
