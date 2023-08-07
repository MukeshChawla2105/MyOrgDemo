({
    doinit : function(component, event, helper){
        component.set("v.showtabOne",true);
    },
	ShowFirsttab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",true);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabFour",false);
        component.set("v.showtabFive",false);
        component.set("v.showtabSix",false);
        
        
    },
 ShowSecondtab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",true);
        component.set("v.showtabthree",false);
        component.set("v.showtabFour",false);
        component.set("v.showtabFive",false);
        component.set("v.showtabSix",false);
        
        
    },
        Showthirdtab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",true);
        component.set("v.showtabFour",false);
        component.set("v.showtabFive",false);
        component.set("v.showtabSix",false);
        
        
    },
        ShowFourthtab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabFour",true);
        component.set("v.showtabFive",false);
        component.set("v.showtabSix",false);
        
        
    },
        ShowFifthtab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabFour",false);
        component.set("v.showtabFive",true);
        component.set("v.showtabSix",false);
        
        
    },
 
        Showsixthtab :function(component, event, helper){
        debugger;
       
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabFour",false);
        component.set("v.showtabFive",false);
        component.set("v.showtabSix",true);
        
        
    },

})