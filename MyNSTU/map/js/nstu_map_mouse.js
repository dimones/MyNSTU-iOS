//MOUSE/TOUCH EVENTS
var mouse_moving;
var mouse_move_prev = {};
var mouse_down_pos = {};
//var mouse_up_pos={};
var touch_zoom_prev_l;

function mouse_event_is_click_only()
{
    var d = Math.sqrt(Math.pow(mouse_down_pos.x - mouse_move_prev.x,2) + Math.pow(mouse_down_pos.y - mouse_move_prev.y,2));
    if (d <= mouse_click_max_d)
        return true;
    return false;
}

function mouse_click_event(eventData)
{
    if (!mouse_event_is_click_only()) return;
    var x, y;
    if (eventData.type == "tap")
    {
        var t = eventData.touches[0];
        x = t.clientX;
        y = t.clientY;
    }
    else
    {
        x = eventData.x
        y = eventData.y
    }

    if (schedule_endabled)
    {
        var f = conv_to_inner_level_coord(x, y - html_top_px, ratio);
        var info = schedule_click_class_info(d_floor, f.x, f.y);
        if (info != null)
            schedule_show_pop(info,x,y);
        else
            schedule_hide_pop();
    }
}

function mouse_down_event(eventData)
{
    //if (eventData.type == "mousedown" && eventData.button == 0)
    //{
    if (level_conatainer == null) return;

    var x, y;
    if (eventData.type == "mousedown")
    {
        x = eventData.x
        y = eventData.y
    }
    if (eventData.type == "touchstart")
    {
        var t = eventData.touches[0];
        x = t.clientX;
        y = t.clientY;

        if (eventData.touches.length == 2)
        {
            x = x - eventData.touches[1].clientX;
            y = x - eventData.touches[1].clientY;
            touch_zoom_prev_l = Math.sqrt(x * x + y * y);
            mouse_moving = true;
            //return;
        }
    }
    mouse_down_pos.x = x;
    mouse_down_pos.y = y;

    mouse_move_prev.x = x;
    mouse_move_prev.y = y;
    mouse_moving = true;
    //}
}

function mouse_up_event(eventData)
{
    if (level_conatainer == null) return;

    mouse_moving = false;
    
    schedule_hide_pop();
    
    if (eventData.type == "mouseup")
        mouse_click_event(eventData);
	else    
	{
        fakeEventData = {};
        fakeEventData.touches = {0:{clientX:eventData.pageX,clientY:eventData.pageY}};
        fakeEventData.type = "tap";
        mouse_click_event(fakeEventData);
    }
}

function mouse_move_event(eventData)
    {
        if (level_conatainer == null) return;

        if (mouse_moving)
        {
            var x, y;
            if (eventData.type == "mousemove")
            {
                x = eventData.x
                y = eventData.y
            }
            if (eventData.type == "touchmove")
            {
                var t = eventData.touches[0];
                x = t.clientX;
                y = t.clientY;

                // if (eventData.touches.length == 2)
                // {
                //     touch_zoom(eventData.touches);
                //     return;
                // }
                if (eventData.touches.length > 1)
                    return;
            }

            var dx = x - mouse_move_prev.x;
            var dy = y - mouse_move_prev.y;

            move_to_d(dx, dy);

            mouse_move_prev.x = x;
            mouse_move_prev.y = y;
        }
    }
    //--------------------------------------------

//ZOOM
function button_zoom(z)
{
    if (level_conatainer == null) return;

    var fakeEventData = {};
    fakeEventData.x = render_width / 2;
    fakeEventData.y = (render_heigh - offset_y) / 2;
    fakeEventData.wheelDeltaY = z * zoom_button_step;
    fakeEventData.type = "mousewheel";
    zoom_event(fakeEventData);
}

function touch_zoom(touches)
{
    if (level_conatainer == null) return;

    var t = touches[0];
    var x1 = t.clientX;
    var y1 = t.clientY;
    t = touches[1];
    var x = (x1 + t.clientX) / 2;
    var y = (y1 + t.clientY) / 2;

    x1 = x1 - t.clientX;
    y1 = y1 - t.clientY;

    var d = Math.sqrt(x1 * x1 + y1 * y1);
    d = d - touch_zoom_prev_l;

    var fakeEventData = {};
    fakeEventData.x = x;
    fakeEventData.y = y;
    fakeEventData.wheelDeltaY = d * touche_san;
    fakeEventData.type = "mousewheel";

    zoom_event(fakeEventData);

    touch_zoom_prev_l = d;
}

function zoom_event(eventData)
{
    if (level_conatainer == null) return;
    if (eventData.type != "mousewheel") return;
    var d = eventData.wheelDeltaY;
    var x = eventData.x;
    var y = eventData.y - html_top_px;

    var d = zoom_d * d;

    zoom_value += d;
    if (zoom_value < 1)
        zoom_value = 1;
    if (zoom_value > max_zoom)
        zoom_value = max_zoom;

    var pre_ratio = ratio;
    ratio = level_ratio * zoom_value;
    level_conatainer.scale.x = level_conatainer.scale.y = ratio;

    if (zoom_value == 1)
    {
        level_conatainer.x = level_tocenter_position.x;
        level_conatainer.y = level_tocenter_position.y;
        level_move_position.x = level_move_position.y = 0;
        return;
    }

    reposition_zoom(x, y, pre_ratio, ratio);
}

function reposition_zoom(x, y, from_ration, to_ration)
{
    var f = conv_to_ratio_level_coord(x, y, to_ration);
    var fx = f.x;
    var fy = f.y;

    var dx = x - (fx / from_ration);
    var dy = y - (fy / from_ration);

    level_conatainer.x = dx; // + level_move_position.x;
    level_conatainer.y = dy; //+ level_move_position.y;
}

function conv_to_ratio_level_coord(x, y, _ratio)
{
    var dx = level_conatainer.x;
    var dy = level_conatainer.y;

    var fx = (x - dx) * _ratio;
    var fy = (y - dy) * _ratio;

    var pos = {};
    pos.x = fx;
    pos.y = fy;
    return pos;
}

function conv_to_inner_level_coord(x, y, _ratio)
    {
        var dx = level_conatainer.x;
        var dy = level_conatainer.y;

        var fx = (x - dx) / _ratio;
        var fy = (y - dy) / _ratio;

        var pos = {};
        pos.x = fx;
        pos.y = fy;
        return pos;
    }
    //--------------------------------------------

//RESIZE
function calc_render_size()
{
    render_width = window.innerWidth;
    render_heigh = window.innerHeight - html_top_px - html_foot_px - offset_fix_bottom;
}

function calc_level_ratio()
{
    var bx = d_floor.floor_size.x + d_build.coord.x;
    var by = d_floor.floor_size.y + d_build.coord.y;

    level_width = bx;
    level_height = by;

    bx = (render_width - offset_x) / build_ratio / bx;
    by = (render_heigh - offset_y) / build_ratio / by;

    level_ratio = Math.min(bx, by);

    prev_ratio = ratio;
    ratio = level_ratio * zoom_value;

    return level_ratio;
}

function calc_build_ratio()
{
    build_ratio = 1;
    return build_ratio;
}


function resize_event()
{
    if (level_conatainer == null) return;

    calc_render_size();

    renderer.resize(Math.ceil(render_width), Math.ceil(render_heigh));

    calc_build_ratio();
    calc_level_ratio();
    stage.scale.x = stage.scale.y = build_ratio;
    if (level_conatainer != null)
        level_conatainer.scale.x = level_conatainer.scale.y = ratio;

    if (zoom_value != 1)
        reposition_zoom(render_width / 2, render_heigh / 2, prev_ratio, ratio);
}
//--------------------------------------------