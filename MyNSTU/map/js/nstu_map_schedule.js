var schedule;

var schedule_container = null;
var schedule_graphics = null;

var schedule_container_legend = null;
var schedule_graphics_legend = null;

var schedule_busy_alpha = 0.5;
var schedule_busy_color = 0xEE0000;
var schedule_busy_my_group_color = 0x00FF00;

var schedule_my_group = "";

var schedule_pop_visible = false;

function getWeekNumber(termBegin) {
    var cur = new Date;
    var temp = termBegin.split(/\./);
    var begin = new Date(temp[2], temp[1] - 1, temp[0]);
    var d = (cur - begin)  / 1000 / 60 / 60 / 24 / 7;

    return parseInt(d) + 1;
}

function schedule_set_day_pair_odd_now(week_num)
{
    //odd: 0 чет, 1 неч, -1 оба
    var ret = {};
    var date = new Date();
    ret.day = date.getDay();
    if (ret.day == 0)
    {
        ret.day++;
        week_num++;
        ret.pair = 1;    
    }
    else
    {
        var ps = {2:9*60+55,3:11*60+35,4:13*60+15,5:15*60+10,6:16*60+50,7:18*60+30,8:20*60}
        var t = date.getHours()*60+date.getMinutes();
        ret.pair = 1;
        for (var p in ps)
        {
            if (t>ps[p])
                ret.pair = p;
        }
        if (ret.pair == 8)
        {
            ret.day = (ret.day + 1) % 7;
            if (ret.day == 0)
            {
                ret.day++;
                week_num++;
            }
            ret.pair = 1;
        }
    }
    
    schedule_set_pair(ret.pair,false);
    schedule_set_day(ret.day,false);
    schedule_set_odd(week_num,false);
    
    return ret;
}

function schedule_get_week()
{
    $.get(server_address + "2/get_semester_begin")
    .done(function(data)
    {
        var b = getWeekNumber(JSON.parse(data).semester_begin);
        schedule_set_day_pair_odd_now(b);
    })
    .fail(function(data)
    {
        var err = "OOPS!\nget_semestr_begin failed";
        console.log(err);
        console.log(data);
        //alert(err);
    });
}

function schedule_legend_add_to_stage(legend2w,h,y,font_legend,text_scale,stage)
{
    schedule_container_legend = new PIXI.Container();
    schedule_graphics_legend = new PIXI.Graphics();
    schedule_container_legend.addChild(schedule_graphics_legend);
    
    schedule_graphics_legend.beginFill(schedule_busy_color, 0.5);
    schedule_graphics_legend.lineStyle(1, schedule_busy_color, 0.5);
    schedule_graphics_legend.drawRect(0, y, legend2w, h);
    schedule_graphics_legend.endFill();
    
    var legend_text = new PIXI.Text("Другие группы",
    {
        font: font_legend,
        fill: "black",
        align: "center"
    });
    legend_text.anchor.x = legend_text.anchor.y = 0.5;
    legend_text.scale.x = legend_text.scale.y = text_scale;
    legend_text.position.set(0 + legend2w / 2, y + h / 2);
    schedule_container_legend.addChild(legend_text);
    
    if (schedule_my_group != undefined)
    {
        schedule_graphics_legend.beginFill(schedule_busy_my_group_color, 0.5);
        schedule_graphics_legend.lineStyle(1, schedule_busy_my_group_color, 0.5);
        schedule_graphics_legend.drawRect(legend2w, y, legend2w, h);
        schedule_graphics_legend.endFill(); 
        
        legend_text = new PIXI.Text(schedule_my_group,
        {
            font: font_legend,
            fill: "black",
            align: "center"
        });
        legend_text.anchor.x = legend_text.anchor.y = 0.5;
        legend_text.scale.x = legend_text.scale.y = text_scale;
        legend_text.position.set(legend2w + legend2w / 2, y + h / 2);
        schedule_container_legend.addChild(legend_text);
    }
    stage.addChild(schedule_container_legend);
    schedule_container_legend.visible = false;
}

function schedule_hide_pop()
{
    if (schedule_pop_visible)
    {
        $('#pop').click();
        schedule_pop_visible = false;
    }
}

function schedule_show_pop(info,x,y)
{
    schedule_hide_pop();
    var pop = $('#pop');
    pop.css('left',x);    
    pop.css('top',y);
    var title = '<font color="white">'+info.title+'</font>';
    
    var content = "";
    for (var p in info.persons)
    {
        var per = info.persons[p];
        content+='<a href="'+per.link+'"><u><font color="#00cc66">'+per.name+'<font></u></a><br>';
    }
    content+='<font color="white">'
    for (var g in info.groups)
    {
        var group = info.groups[g];
        content+='<br>'+group;
    }
    content+='</font>';
    
    //pop.attr("title",title);
    content = title+'<br><br>'+content;
    pop.attr("data-content",content);
    
    pop.click();
    schedule_pop_visible = true;
}

function schedule_floor_rooms_recting(d_floor)
{
    var room;
    for (var r in d_floor.rooms)
    {
        room = d_floor.rooms[r];
        room["pixi_rect"] = new PIXI.Rectangle(room.coord1.x, level_y_begin - room.coord2.y,
            room.coord2.x - room.coord1.x, room.coord2.y - room.coord1.y);
    };
    d_floor.rooms_pixi_rected = true;
}

function get_schedule(floor, day, pair, odd, callback_success)
{
    $.get(server_address + "getGroupsFromFloor?floor=" + floor + "&day=" + day + "&pair=" + pair + "&odd=" + odd)
        .done(function(data)
        {
            schedule = JSON.parse(data);
            console.log(data);
            if (callback_success != undefined)
                callback_success();
            else
                console.log("callback_success is indefined");
        })
        .fail(function(data)
        {
            var err = "OOPS!\nSchedule loading failed\n" + "day=" + day + " pair=" + pair + " odd=" + odd;
            console.log(err);
            console.log(data);
            alert(err);
        });
}

function get_clicked_room(floor, x, y)
{
    if (floor.rooms_pixi_rected != true)
    {
        console.log("Level " + floor.level + " not pixi rected");
        return;
    }
    var room;
    for (var r in floor.rooms)
    {
        room = floor.rooms[r];
        if (room.pixi_rect.contains(x, y))
            return room;
    };
    return null;
}

function get_schedule_of_room(room)
{
    var gs = schedule[room.assign];
    if (gs == undefined)
        return null;
    return gs;
}

function schedule_click_class_info(floor, x, y)
{
    var room = get_clicked_room(floor, x, y);
    if (room == null)
        return null;
    else
    {
        gstr = "";
        var sch = get_schedule_of_room(room);
        if (sch == null)
            return null;
//        else
//            for (var g in sch.groups)
//                gstr += "<br>" + sch.groups[g];

        var ret = {};
        ret.title = room.assign + '<br>'+ schedule[room.assign].discname;
        ret.persons = sch.persons;
        ret.groups = sch.groups;
        
        return ret;
    }
}

function get_busy_rooms(floor)
{
    var rs = [];
    var sch;
    for (r in floor.rooms)
    {
        sch = schedule[floor.rooms[r].assign];
        if (sch != undefined)
            rs.push(floor.rooms[r]);
    }
    return rs;
}

function schedule_group_in_busy_room(group, room)
{
    var sch = get_schedule_of_room(room);
    if (sch == null)
        return false;
    else
        for (var g in sch.groups)
            if (sch.groups[g] === group)
                return true;

    return false;
}

function update_schedule_container(floor, level_conatainer, level_y_begin)
{
    if (level_conatainer != null)
        remove_schedule_container(level_conatainer);
    else
        return;
    
    schedule_container_legend.visible = true;

    schedule_container = new PIXI.Container();
    schedule_graphics = new PIXI.Graphics();
    schedule_container.addChild(schedule_graphics);

    var br = get_busy_rooms(floor);

    for (var broom in br)
    {
        var b = br[broom];
        var color = schedule_busy_color;
        if (schedule_group_in_busy_room(schedule_my_group, b))
            color = schedule_busy_my_group_color;

        schedule_graphics.beginFill(color, schedule_busy_alpha);
        schedule_graphics.lineStyle(1, color, schedule_busy_alpha);
        schedule_graphics.drawRect(b.coord1.x, level_y_begin - b.coord2.y, b.coord2.x - b.coord1.x, b.coord2.y - b.coord1.y);
        schedule_graphics.endFill();
    }

    level_conatainer.addChild(schedule_container);
}

function remove_schedule_container(level_conatainer)
{
    if (schedule_container != null)
    {
        level_conatainer.removeChild(schedule_container);
        //schedule_container.destroy();
        schedule_container_legend.visible = false;
    }
}