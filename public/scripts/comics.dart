import 'dart:html';
import 'dart:json';

main() {
  load_comics();
}

load_comics() {
  var list_el = document.query('#comics-list')
    , req = new HttpRequest();

  req.open('get', '/comics', true);

  req.on.load.add((res) {
    var list = JSON.parse(req.responseText);
    list_el.innerHTML = graphic_novels_template(list);
    attach_delete_handlers(list_el);
  });

  req.send();
}

attach_delete_handlers(parent) {
  parent.queryAll('.delete').forEach((el) {
    el.on.click.add((event) {
      delete(event.target.parent.id, callback:() {
        print("[delete] ${event.target.parent.id}");
        event.target.parent.remove();
      });
      event.preventDefault();
    });
  });
}

delete(id, {callback}) {
  var req = new HttpRequest()
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
    html = html.concat(graphic_novel_template(graphic_novel));
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