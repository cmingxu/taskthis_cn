Object.extend(Form, {

   disable: function( form ) {
      var elements = Form.getElements( form );
      for(var i=0; i<elements.length; i++)
      {
         elements[i].blur();
         elements[i].disable = 'true';
      }
   },

   focus_first: function( form )
   {
      form = $(form);
      var elements = Form.getElements( form );
      for( var i=0; i<elements.length; i++ ) {
         var elem = elements[i];
         if( elem.type != 'hidden' && !elem.disabled) {
            Field.activate( elem );
            break;
         }
      }
   },

   reset: function( form )
   {
      $(form).reset();
   }

} );

/*--------------------------------------------------------------------------*/

Object.extend(Field, {

   select: function(element) {
      $(element).select();
   },

   activate: function(element) {
      $(element).focus();
      $(element).select();
   },
   
   disable: function(element) {
      $(element).blur();
      $(element).disabled = 'true';
   },
   
   enable: function(element) {
      $(element).disabled = '';
   }

});



/*--------------------------------------------------------------------------*/

Object.extend(Array.prototype, {

   contains: function( value, s ) {
      return this.index_of( value, 0, s ) !== -1;
   },

   index_of: function( value, start, strict ) {
      start = start || 0;
      for (var i=start; i<this.length; i++) {
         var item = this[i];
         if (strict ? item === value :
             Var.is_regexp(value) ? value.test(item) :
             Var.is_function(value) ? value(item) :
             item == value)
               return i;
      }
      return -1;
   },

   remove: function( value, all, strict ) {
      while (this.contains(value,strict)) {
         this.splice(this.index_of(value,0,strict), 1);
         if (!all) break
      }
      return this;
   }

});

/*--------------------------------------------------------------------------*/
if (!window.Element) {
  var Element = new Object();
}

Object.extend(Element, {
   
   has_class: function(dom, classname) {
       return $(dom).className.split(' ').contains(classname);
   },

   add_class: function(dom, classname) {
      var elem = $(dom);
      if (elem.className.split(' ').contains(classname)) return;
      elem.className += ( elem.className.length ? ' ' : '' ) + classname;
   },

   remove_class: function(dom, classname) {
      var elem = $(dom);
      elem.className = elem.className.split(' ').remove(classname).join(' ');
   },

   toggle_class: function(dom, classname) {
      if ( this.has_class( dom, classname ) ) 
         this.remove_class( dom, classname ); 
      else 
         this.add_class( dom, classname );
      return !!this.has_class( dom, classname );
   },

   get: function(obj) {
      return $(obj);
   },

   get_with_class: function(className, parent_element) {
      var children = (parent_element || document).getElementsByTagName('*');
      var elements = new Array();

      for (var i = 0; i < children.length; i++) {
         if( this.has_class( children[i], className ) )
               elements.push(child);
      }

      return elements;
   },

   get_list: function (el) {
      if( Var.is_element(el) )  
         return [el];
      else if( Var.is_string(el) ) 
         return this.get_list(el.split(/\s+/g));
      else if( Var.is_list(el) ) {
         var r = map(el, this.get);
         return filter(r, Var.is_element).length==r.length? r : null;
      }
      else 
      return null;
   },

   get_height: function(el) {
      el = $(el);
      return el.offsetHeight; 
   }
});

/*--------------------------------------------------------------------------*/

Effect.SlideDown = function(element) {
  element = $(element);
  element.style.height   = '0px';
  Element.makeClipping(element);
  Element.cleanWhitespace(element);
  Element.makePositioned(element.firstChild);
  Element.show(element);
  new Effect.Scale(element, 100, 
   Object.extend({ scaleContent: false, 
    scaleX: false, 
    scaleMode: 'contents',
    scaleFrom: 0,
    afterUpdate: function(effect) 
      { effect.element.firstChild.style.bottom = 
          (effect.originalHeight - effect.element.clientHeight) + 'px'; },
    afterFinish: function(effect) 
      {  Element.undoClipping(effect.element); }
    }, arguments[1] || {})
  );
}



/*--------------------------------------------------------------------------*/

Var = {
   is_array:    function(o) { return (this.is_object(o) && o.constructor == Array); },
   is_bool:     function(o) { return (typeof o == 'boolean'); },
   is_function: function(o) { return (typeof o == 'function'); },   
   is_null:     function(o) { return (typeof o == 'object' && !o); },
   is_number:   function(o) { return (typeof o == 'number' && isFinite(o)); },
   is_object:   function(o) { return (o && typeof o == 'object') || this.is_function(o) },
   is_regexp:   function(o) { return (o && o.constructor == RegExp); },
   is_string:   function(o) { return (typeof o == 'string'); },
   is_undef:    function(o) { return (typeof o == 'undefined'); },
   is_element:  function(o, strict) { return o && this.is_object(o) && ((!strict && (o==window || o==document)) || o.nodeType == 1); },
   is_list:     function(o) { return o && this.is_object(o) && (this.is_array(o) || o.item); }
};


/*--------------------------------------------------------------------------*/
// DOM EVENTS

Events = {
   ALLOW_LEGACY_EVENTS: true,

   get_model: function() { return document.addEventListener? 'DOM':document.attachEvent? 'IE':'legacy'; },

   subscribe: function(elems, evt, fnc, capture) {
      if (!this.ALLOW_LEGACY_EVENTS && this.get_model()=='legacy') return false;
      capture = capture || true;

      function DOM_addEvent   (el, ev, fn, capture) { el.addEventListener(ev, fn, capture) }
      function legacy_addEvent(el, ev, fn) {
         var evn = 'on'+ev;
         if (!el[evn] || !el[evn].handlers) {
            el[evn] = function() {
               map(el[evn].handlers, function(h){  h( new (el.attachEvent?IE_Event:Legacy_Event)(el) ) });
            }
            el[evn].handlers = [];
         }
         el[evn].handlers.push(fn);
      }
      var addEventFn = this.get_model()=='DOM'? DOM_addEvent : legacy_addEvent;
      map(Element.get_list(elems), function(el) { addEventFn(el, evt, fnc, capture) });
   },

   unsubscribe: function (els, ev, fn, capture) {
      if (!this.ALLOW_LEGACY_EVENTS && this.get_model()=='legacy') return false;
      capture = capture || true;
      var model = this.get_model();
      map(Element.get_list(els), function(el) {
         if(model=='DOM') 
            el.removeEventListener(ev, fn, capture);
         else 
            el['on'+ev].handlers.remove(fn);
      });
   },

   subscribe_all: function (elem, evnts, capture) {
      for (ev in evnts) Events.subscribe(elem, ev, evnts[ev], capture);
   },

   on_load: function (fn) {
      // opera onload is in document, not window
      var w = this.get_model()=="DOM" && !window.addEventListener ? document : window;
      return Events.subscribe(w, 'load', fn, true)
   }

};


function IE_Event(currentTarget) {
    this.currentTarget   = currentTarget;
    this.preventDefault  = function() { window.event.returnValue  = false }
    this.stopPropagation = function() { window.event.cancelBubble = true }
    this.target  = window.event.srcElement;
    var self = this;
    // direct equivalence properties
    list('altKey,ctrlKey,shiftKey,clientX,clientY').map(function(p){ self[p] = event[p] });
    return this;
}

function Legacy_Event(currentTarget) {
    this.currentTarget   = currentTarget;
    return this;
}

/*--------------------------------------------------------------------------*/
// General helper methods from http://v2studio.com/k/code/lib/lib_c.js

function map(list, fn) {
   if ( Var.is_string(fn) )
      return map(list, __strfn('item,idx,list', fn));

   var result = [];
   fn = fn || function(v) {return v};
   for (var i=0; i < list.length; i++) 
      result.push(fn(list[i], i, list));

   return result;
}

function list(s, sep) {
   if (!Var.is_string(sep) && !Var.is_regexp(sep))
      sep = sep? ',' : /\s*,\s*/;
   return s.split(sep);
}

function __strfn(args, fn) {
   function quote(s) { return '"' + s.replace(/"/g,'\\"') + '"' }
   if (!/\breturn\b/.test(fn)) {
      fn = fn.replace(/;\s*$/, '');
      fn = fn.insert(fn.lastIndexOf(';')+1, ' return ');
   }
   return eval('new Function('
        + map(args.split(/\s*,\s*/), quote).join()
        + ','
        + quote(fn)
        + ')'
        );
}
