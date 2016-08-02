var getUrlParameter = function getUrlParameter(sParam)
{
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++)
    {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam)
        {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

var url_prm_class_value = null;

$(window).load(function()
{
    //mynstuOnLoad();
    $('[data-toggle="popover"]').popover({html:true}); 
    $('[data-toggle="tooltip"]').tooltip({html:true}); 
    //$('#pop').click();

    
    $.getJSON("nstu_map_data.json",
        function(json)
        {
            url_prm_class_value = getUrlParameter("room");

            initMap(json);
        
            schedule_get_week();
        });
});

//$(document).ready(function(){
//        
//});

//consts
var offset_y = 120;
var offset_x = 80;
var offset_fix_bottom = 0;
var min_stage_width = 400;
var max_zoom = 4;
var zoom_d = 0.001;
var touche_san = 0.1;
var legend_w = 90;
var stair_d = 15;
var text_scale = 0.6;
var zoom_button_step = 200;
var mouse_click_max_d = 10;
var selected_class_color = 0x00FFFF;

var selected_class = null;
var selected_class_container;
var selected_class_graphics;

var selected_class_hide = false;

//fonts
var font_info = "bold 25px Console";
var font_room = "bold 40px Console";
var font_legend = "bold 24px Console";

var js_engine_version = "0.4.5";

var map, map_types;

//pixi objects
var stage, level_conatainer, level_graphics, stage_graphics, renderer;

var stage_level_text;

var render_width, render_heigh;
var level_width, level_height;
var level_ratio, build_ratio, prev_ratio, ratio;
var html_top_px, html_foot_px;

var level;
var d_build, d_floor;

var zoom_value = 1;
var level_tocenter_position = {};
//var level_zoom_position = {};
var level_move_position = {
    x: 0,
    y: 0
};

function initMap(map_data)
{
    html_top_px = 0;//$("#navbar").height();
    html_foot_px = 0;//$("#footer").height();
    //html_foot_px = document.getElementById("footer").height();
    if (html_foot_px == null)
        html_foot_px = 0;

    //mapdata = get_map_data();

    map = map_data.map;
    map_types = map_data.map_types;

    if (js_engine_version != map_types.version)
    {
        alert("OOPS!\nError matching map engine versions :(\nRequire: " + js_engine_version + "\nDetected: " + map_types.version);
        return;
    }

    xs_map_typing();

    d_build = map.builds[7];

    level = 1;

    $("#canv").height(window.innerHeight - html_foot_px - html_top_px);
    calc_render_size();

    renderer = PIXI.autoDetectRenderer(render_width, render_heigh,
    { /*antialias: true, */
        transparent: true
    });
    renderer.backgroundColor = map_types.map_background_type.color;

    document.getElementById("canv").appendChild(renderer.view);

    stage = level_conatainer = level_graphics = stage_graphics = null;

    var canv_element = document.getElementById("canv");

    window.addEventListener("resize", resize_event);

    canv_element.addEventListener('mousewheel', zoom_event);
    canv_element.addEventListener('mousedown', mouse_down_event);
    canv_element.addEventListener('mouseup', mouse_up_event);
    canv_element.addEventListener('mousemove', mouse_move_event);

    canv_element.addEventListener("touchstart", mouse_down_event);
    canv_element.addEventListener("touchend", mouse_up_event);
    canv_element.addEventListener("touchcancel", mouse_up_event);
    canv_element.addEventListener("touchmove", mouse_move_event);

    //canv_element.addEventListener("click", mouse_click_event);
//    canv_element.addEventListener("tap", mouse_click_event);
    //$("#canv").on("click",mouse_click_event);
    //$("#canv").on("tap",mouse_click_event);

    schedule_set_day(1, false);
    schedule_set_pair(1, false);
    schedule_set_odd(1, false);
    
    if (url_prm_class_value != undefined)
    {
        selected_class = find_class(url_prm_class_value);
        
        if (selected_class != null)
        {
            level = selected_class.level;
        
            selected_class_container = new PIXI.Container();
            selected_class_graphics = new PIXI.Graphics();
            selected_class_container.addChild(selected_class_graphics);
        }
    }
    
    schedule_my_group = getCookie("userGroup");

    load_stage_container();
    load_level_container_do(level);
    
    animate();
    
    var readme = getCookie("nstu_map_readme");
    if (readme != "1")
    {
        show_f1();
        set_cookie("nstu_map_readme","1");    
    }
}

//INTERFACE
function show_f1(){$('#read_me_modal').modal('show');}

function set_schedule_group(group)
{
    schedule_my_group = group;
}

function load_stage_container()
{
    stage = new PIXI.Container();
    stage.interactive = true;
    stage.scale.x = stage.scale.y = build_ratio;

    stage_level_text = new PIXI.Text("",
    {
        font: font_info,
        fill: "black"
    });
    stage_level_text.scale.x = stage_level_text.scale.y = text_scale;
    stage_level_text.position.x = 10;
    stage_level_text.position.y = 40;

    stage.addChild(stage_level_text);

    draw_legend();
    
    schedule_legend_add_to_stage(legend_w*2,legend_w/5,legend_w/5,font_legend,text_scale,stage);
}

function load_level_container(set_level)
{
    if (selected_class != null)
    {
        selected_class_container.visible = false;
        selected_class = null;            
    }

    load_level_container_do(set_level);
}

function load_level_container_do(set_level)
{
    if (level_conatainer != null)
    {
        stage.removeChild(level_conatainer);
        level_conatainer.destroy();
    }

    zoom_value = 1;
    level_move_position = {
        x: 0,
        y: 0
    };

    level = set_level;
    d_floor = d_build.floors[level];

    level_conatainer = new PIXI.Container();
    if (level_graphics != null)
        level_graphics.clear();
    else
        level_graphics = new PIXI.Graphics();

    level_conatainer.addChild(level_graphics);
    stage.addChild(level_conatainer);

    var inf;
    if (d_floor != undefined)
    {
        resize_event();
        resize_event(); //NEED FOR UPDATE pre_ratio!

        level_tocenter_position = {
            x: 0,
            y: offset_y + (render_heigh - offset_y) / 2 -
                (d_floor.floor_size.y + d_build.coord.y) / 2 * level_ratio
        };
        level_y_begin = d_floor.floor_size.y + d_build.coord.x;

        level_conatainer.y = level_tocenter_position.y;
        level_conatainer.x = level_tocenter_position.x;
        level_conatainer.scale.x = level_conatainer.scale.y = level_ratio;

        if (d_floor.rooms_pixi_rected != true)
            schedule_floor_rooms_recting(d_floor);


        stage_level_text.setText(d_build.name + "\n" + d_floor.name);

        if (selected_class != null)
            level_conatainer.addChild(selected_class_container);
        
        draw_floor(d_floor);
        
        if (schedule_endabled)
            schdeule_RUN_TO_RUN();
    }
    else
    {
        stage_level_text.setText("NO DATA");
    }
}

function move_to_d(dx, dy)
{
    level_move_position.x += dx;
    level_move_position.y += dy;

    level_conatainer.x += dx;
    level_conatainer.y += dy;
}

function move_to(x, y)
{
    level_move_position.x = x;
    level_move_position.y = y;

    level_conatainer.x = x;
    level_conatainer.y = y;
}

function zoom_in(factor)
{
    button_zoom(1 * factor);
}

function zoom_out(factor)
{
    button_zoom(-1 * factor);
}

function zoom_in()
{
    zoom_in(1);
}

function zoom_out()
    {
        zoom_out(-1);
    }
    //--------------------------------------------

//SELECTED ROOM
function find_class(room_object)
{
    var floor, room;
    for (var f in d_build.floors)
    {
        floor = d_build.floors[f];
        for (var c in floor.rooms)
        {
            room = floor.rooms[c];
            if (room.assign === room_object)
            {
                selected_class = room;
                return selected_class;
            }
        }
    }
    return null;
}

function switch_visible_selected_class_container()
{
    if (selected_class == null)
    {
        selected_class_timer = null;
        selected_class_container.visible = false;
        return;
    }
    
    selected_class_container.visible = !selected_class_container.visible;
    
    setTimeout(switch_visible_selected_class_container, 1000);
}

var selected_class_timer = null;

function start_strobe_selected_class()
{
    selected_class_timer = setTimeout(switch_visible_selected_class_container, 1000);
}
//--------------------------------------------

function animate()
{
    renderer.render(stage);
    requestAnimationFrame(animate);
}

// function logo()
// {
//     var sc = 80.0/350;
//     var d = 80;
//     var logo_rect = PIXI.Sprite.fromImage('/static/mynstu/images/srf.png');
//     logo_rect.interactive = true;
//     logo_rect.scale.x = sc;
//     logo_rect.scale.y = sc;
//     logo_rect.position.set((render_width-d)/build_ratio,(render_heigh-d)/build_ratio);
//     stage.addChild(logo_rect);
// }


//DRAWING
function draw_legend()
{
    stage_graphics = new PIXI.Graphics();
    stage.addChild(stage_graphics);

    var w = legend_w;
    var h = w / 5;
    var offx = 0;
    //var pos = {x : (render_width-w+offx)/build_ratio,y : 0};
    var pos = {
        x: 0,
        y: 0
    };
    var backgrounds = map_types.backgrounds;
    for (var b in backgrounds)
    {
        if (backgrounds[b].legend_name == "[NO LEGEND NAME]") continue;

        stage_graphics.beginFill(backgrounds[b].color, 1);
        stage_graphics.lineStyle(1, backgrounds[b].color, 1);
        stage_graphics.drawRect(pos.x, pos.y, w, h);
        stage_graphics.endFill();

        var legend_text = new PIXI.Text(backgrounds[b].legend_name,
        {
            font: font_legend,
            fill: "black",
            align: "center"
        });
        legend_text.anchor.x = legend_text.anchor.y = 0.5;
        legend_text.scale.x = legend_text.scale.y = text_scale;
        legend_text.position.set(pos.x + w / 2, pos.y + h / 2);

        stage.addChild(legend_text);

        pos.x += w;
    }
}

//DRAWERS
function add_text_of_room(room)
{
    var text = new PIXI.Text(room.name,
    {
        font: font_room,
        fill: "black",
        align: "center"
    });
    text.anchor.x = text.anchor.y = 0.5;
    text.position.x = room.real_text_coord.x;
    text.position.y = level_y_begin - room.real_text_coord.y;
    level_conatainer.addChild(text);
}

function draw_stair(stair)
{
    //ЛЕНЬ MODE
    var coord1 = {};
    coord1.x = stair.coord1.x;
    coord1.y = stair.coord1.y;
    var coord2 = {};
    coord2.x = stair.coord2.x;
    coord2.y = stair.coord2.y;
    //coord1.y = render_heigh - coord1.y;
    //coord2.y = render_heigh - coord2.y;

    var length;
    if (stair.orientation == "v")
        length = -(coord2.y - coord1.y);
    else
        length = coord2.x - coord1.x;

    if (!stair.full) length /= 2;

    var fakewall = {}
    fakewall["type"] = stair.wall_type;
    fakewall["width"] = stair.wall_type.width * map_types.map_scale;

    var c2 = {}
    c2.x = coord2.x;
    c2.y = coord2.y;

    if (stair.orientation == "v")
    {
        if (!stair.full)
        {
            coord1.y -= length / 2;
            c2.y += length / 2;
        }

        fakewall["coord1"] = coord1;
        fakewall["coord2"] = coord2;
        fakewall.coord2.y = coord1.y;
    }
    else
    {
        if (!stair.full)
        {
            coord1.x += length / 2;
            c2.x -= length / 2;
        }

        fakewall["coord1"] = coord1;
        fakewall["coord2"] = coord2;
        fakewall.coord2.x = coord1.x;
    }

    var d = stair_d;

    if (stair.orientation == "v")
    {
        for (var i = fakewall.coord1.y; i <= c2.y; i += d)
        {
            fakewall.coord1.y = i;
            fakewall.coord2.y = i;
            draw_wall(fakewall);
        }
    }
    else
    {
        for (var i = fakewall.coord1.x; i <= c2.x; i += d)
        {
            fakewall.coord1.x = i;
            fakewall.coord2.x = i;
            draw_wall(fakewall);
        }
    }

}

function draw_area(area, graphics)
{
    graphics.beginFill(area.type.color, area.alpha);
    graphics.lineStyle(1, area.type.color, area.alpha);
    graphics.drawRect(area.coord1.x, level_y_begin - area.coord2.y, area.coord2.x - area.coord1.x, area.coord2.y - area.coord1.y);
    graphics.endFill();
}

function draw_door(door)
{
    level_graphics.beginFill(door.type.background_type.color, 1);
    level_graphics.lineStyle(1, door.type.background_type.color, 1);
    level_graphics.drawRect(door.coord1.x, level_y_begin - door.coord2.y, door.coord2.x - door.coord1.x, door.coord2.y - door.coord1.y);
    level_graphics.endFill();
}

function draw_wall(wall)
{
    level_graphics.lineStyle(wall.width, wall.type.background_type.color, 1);
    level_graphics.moveTo(wall.coord1.x, level_y_begin - wall.coord1.y);
    level_graphics.lineTo(wall.coord2.x, level_y_begin - wall.coord2.y);
    level_graphics.endFill();
}

function draw_area_selected_room(room)
{
    var fakeArea = {};
    fakeArea["type"] = {
        'color': selected_class_color
    };
    fakeArea["coord1"] = room.coord1;
    fakeArea["coord2"] = room.coord2;
    fakeArea["alpha"] = 0.5;
    draw_area(fakeArea,selected_class_graphics);
}

function draw_floor(floor)
    {
        for (var back in floor.backgrounds)
            draw_area(floor.backgrounds[back],level_graphics);

        for (var wall in floor.walls)
            draw_wall(floor.walls[wall]);

        for (var stair in floor.stairs)
            draw_stair(floor.stairs[stair]);

        for (var door in floor.doors)
            draw_door(floor.doors[door]);

        for (var room in floor.rooms)
        {
            if (floor.rooms[room] === selected_class)
            {
                start_strobe_selected_class();
                draw_area_selected_room(floor.rooms[room]);
            }
            add_text_of_room(floor.rooms[room]);
        }
    }
    //--------------------------------------------

//PREPARE MAPDATA
function xs_convert_color(color)
{
    var b = Math.floor(color % 128) * 2;
    color = Math.floor(color / 128);
    var g = Math.floor(color % 128) * 2;
    var r = Math.floor(color / 128) * 2;
    var c = r * 256 * 256 + g * 256 + b;
    return c;
}

function xs_map_typing()
{
    for (var b in map_types.backgrounds)
        map_types.backgrounds[b].color = xs_convert_color(map_types.backgrounds[b].color);

    for (var w in map_types.walls)
        map_types.walls[w]["background_type"] = map_types.backgrounds[map_types.walls[w].background_type_id];

    for (var d in map_types.doors)
        map_types.doors[d]["background_type"] = map_types.backgrounds[map_types.doors[d].background_type_id];

    map_types["map_background_type"] = map_types.backgrounds[map_types.map_background_id];

    for (var b in map.builds)
    {
        var build = map.builds[b];
        for (var f in build.floors)
        {
            var floor = build.floors[f];

            floor.stairs.forEach(function(item, i, arr)
            {
                floor.stairs[i]["wall_type"] = map_types.walls[item.wall_type_id];
            });

            floor.walls.forEach(function(item, i, arr)
            {
                floor.walls[i]["type"] = map_types.walls[item.type_id];
            });

            floor.doors.forEach(function(item, i, arr)
            {
                floor.doors[i]["type"] = map_types.doors[item.type_id];
            });
            floor.logos.forEach(function(item, i, arr)
            {
                floor.logos[i]["type"] = map_types.logos[item.type_id];
            });
            floor.backgrounds.forEach(function(item, i, arr)
            {
                floor.backgrounds[i]["type"] = map_types.backgrounds[item.type_id];
                floor.backgrounds[i]["alpha"] = 1;
            });
        }
    }
}
