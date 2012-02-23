#import('dart:html');
#import('dart:json');

main() {
  load_comics();

  attach_create_handler();
}

attach_create_handler() {
  document.
    query('#add-comic').
    on.
    click.
    add(enable_create_form);
}

enable_create_form(event) {
  final form_div = _ensure_create_form('add-comic-form');

  print(document.query('#add-comic-form'));

  _show_form(form_div);
  _attach_form_handlers(form_div);
}

_ensure_create_form(id_selector) {
  var form_div = document.query("#${id_selector}");
  if (form_div != null) form_div.remove();

  print(document.query('#add-comic-form'));

  form_div = new Element.html("""
<div id="$id_selector">
${form_template()}
</div>
""");

  document.body.nodes.add(form_div);

  return form_div;
}

_show_form(form_container) {
  form_container.style.transition = 'opacity 1s ease-in-out';
  form_container.style.opacity = "1";
}

_attach_form_handlers(form_container) {
  form_container.query('form').on.submit.add((event) {
    event.preventDefault();
    _submit_create_form(event.target);
  });

  form_container.queryAll('a').forEach((el) {
    el.on.click.add((event) {
      event.preventDefault();
      _disable_create_form(event);
    });
  });
}

_submit_create_form(form) {
  var title = form.query('input[name=title]')
    , author = form.query('input[name=author]')
    , format = form.queryAll('input[name=format]');

  print("title: ${title.value}");
  print("author: ${author.value}");
  print(format);

  var data = {'title':title.value, 'author':author.value}
    , json = JSON.stringify(data);

  print(json);

  var req = new XMLHttpRequest();
  req.open('post', '/comics', false);
  req.setRequestHeader('Content-type', 'application/json');
  req.send(json);
  print(req.responseText);
}

_disable_create_form(event) {
  final form_div = document.query('#add-comic-form');

  print(form_div);

  form_div.style.opacity = "0";

  form_div.queryAll('a').forEach((el) {
    el.on.click.remove(_disable_create_form);
    event.preventDefault();
  });
}

load_comics() {
  var list_el = document.query('#comics-list')
    , req = new XMLHttpRequest();

  attach_handler(list_el, 'click .delete', (event) {
    print("[delete] ${event.target.parent.id}");
    delete(event.target.parent.id, callback:() {
      event.target.parent.remove();
    });
  });

  req.open('get', '/comics', true);

  req.on.load.add((res) {
    var list = JSON.parse(req.responseText);
    print(req.responseText);
    list_el.innerHTML = graphic_novels_template(list);
  });

  req.send();
}

attach_handler(parent, event_selector, callback) {
  var index = event_selector.indexOf(' ')
    , event_type = event_selector.substring(0,index)
    , selector = event_selector.substring(index+1);

  parent.on[event_type].add((event) {
    var found = false;
    parent.queryAll(selector).forEach((el) {
      if (el == event.target) found = true;
    });
    if (!found) return;

    print(event.target.parent.id);
    callback(event);

    event.preventDefault();
  });
}

delete(id, [callback]) {
  var req = new XMLHttpRequest()
    , default_callback = (){};

  req.on.load.add((res) {
    (callback != null ? callback : default_callback)();
  });

  req.open('delete', '/comics/$id', true);
  req.send();
}

graphic_novels_template(list) {
  var html = '';
  list.forEach((graphic_novel) {
    html += graphic_novel_template(graphic_novel);
  });
  return html;
}

graphic_novel_template(graphic_novel) {
  return """
    <li id="${graphic_novel['id']}">
      ${graphic_novel['title']}
      <a href="#" class="delete">[delete]</a>
    </li>""";
}

form_template([graphic_novel]) {
  return """
<form action="comics" id="new-comic-form">
<p>
<label>Title<br/>
<input type="text" name="title" id="comic-title"/>
</label></p>

<p>
<label>Author<br/>
<input type="text" name="author" id="comic-author"/>
</label></p>

<p>Format
<p>
<label>
<input type="checkbox" name="format" value="tablet" id="comic-table"/>
Tablet</label></p>
<p>
<label>
<input type="checkbox" name="format" value="dead-tree" id="comic-dead-tree"/>
Dead Tree</label></p>
</p>

<p>
<input type="submit" value="Bazinga!"/></p>
<a href="#">Cancel</a>
</form>
""";
}