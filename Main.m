function Main()
% @copy GPL version 3

%% Settings
clc;close all;clear;

%% create img cell
img = {};

%% gui code
% Main Figuare GUI
figure("Position",[200 100 950 500],"MenuBar","none"...
    ,"Resize","off");

imgs_path_list = ["coloredChips.png","cameraman.tif"]; % TODO put new images directories here
imgs_list = ["coloredChips.png","cameraman.tif","Choose another image ..."];

% Pop menu to choose image from
cimg = uicontrol("Style","popupmenu");
set(cimg,"Position",[445 455 120 40]);
set(cimg,"String",imgs_list);
set(cimg,"Callback",@assign_img);

add_help_button(gcf,"About this software",...
    "This software made for image processing course in "...
    +"<a href=""https://ucas.edu.ps/"">UCAS</a> "...
    +"by <a href=""https://github.com/khalil2535"">Mahmoud Khalil</a> "...
    +"for Dr.<a href=""https://sites.google.com/ucas.edu.ps/adahdooh"""...
    +">Ahmed Aldahdooh</a>.<br><br>"...
    +"How to use this program ? <br>"...
    +"Just click on button's , It's straight forward !<br><br>"...
    +"what can this software do ?"...
    +"<br> It can embeded & extract secret text inside images using LSB"...
    +" technique. (Least Significant Bit)<br><br>"...
    +"<a href=""https://www.gnu.org/licenses/gpl-3.0.en.html"">License"...
    +"&#169; GPL 3</a><br>"...
    +" This means you are free to use/edit/sell/change this software "...
    +"while you distribute the copy of the modified version along "...
    +"with the software.<br>"...
    +"for more information click on the license above or visit "...
    +"https://www.gnu.org/licenses/gpl-3.0.en.html.");

% Extract GUI code
jLabel = javaObjectEDT('javax.swing.JLabel',...
    '<html><font color="green" size="6">Extract</html>');
javacomponent(jLabel,[60,435,80,40]);


extract_button = uicontrol("Position",[45 175 110 35]);
extract_button.String = "Extract Hidden Text";
extract_button.Callback = @extract;

jTextArea = javaObjectEDT('javax.swing.JTextArea');
javacomponent(jTextArea,[15,220,200,200]);

% Hide GUI code
jLabel = javaObjectEDT('javax.swing.JLabel',...
    '<html><font color="red" size="6">Hide</html>');
javacomponent(jLabel,[840,435,80,40]);

hide_button = uicontrol("Position",[805 175 110 35]);
hide_button.String = "Hide Text";
hide_button.Callback = @hide;

jTextArea = javaObjectEDT('javax.swing.JTextArea');
javacomponent(jTextArea,[770,220,175,200]);

%% Assigning img.Name,Path,Value,Type and showing the image..
    function assign_img(~,~)
        if cimg.String(cimg.Value) == "Choose another image ..."
            % TODO maybe more image formats ?
            [filename, folder]= uigetfile('*.png;*.tif','Select an Image');
            if ~filename
                return;
            end
            img.Name = filename;
            img.Path = [folder filename];
            imgs_list(end) = filename;
            imgs_list(end+1) = "Choose another image ...";
            imgs_path_list(end+1) = img.Path;
            cimg.String = imgs_list;
        else
            img.Name = cell2mat(cimg.String(cimg.Value));
            [~,img_index]= ismember(img.Name,imgs_list,'R2012a');
            img.Path = char(imgs_path_list(img_index));
        end
        
        disp("processing assign_img ..");
        % get image values
        img_info = imfinfo(img.Path);
        img.Type = img_info.ColorType;
        
        if img.Type == "grayscale"
            img.Value = imread(img.Path);
            [img.Width,img.Height]= size(img.Value);
            imshow(img.Value);
        else
            if img.Type == "truecolor"
                img.Value = imread(img.Path);
            else
                % changing indexed to rgb
                [indexed_value,indexed_map] = imread(img.Path);
                img.Value = im2uint8(ind2rgb(indexed_value,indexed_map));
            end
            
            % un used variable contains number 3 (r , g , b)
            [img.Width,img.Height,~]= size(img.Value);
            
        end
        img.Size = img.Width * img.Height;
        imshow(img.Value);
        
        jLabel = javaObjectEDT('javax.swing.JLabel',...
            "<html><font color=""#800080"" size=""3"">Info( Size: "...
            +img.Size+", Type: "+img.Type+" , Width: "+img.Width+...
            " , Height: "+img.Height+" )</html>");
        
        javacomponent(jLabel,[350,10,400,40]);
        disp("assign_img done");
    end

%% Initialize default values
assign_img(cimg);

%% Extract function
    function extract(head,~)
        f_bin = dec2bin(img.Value);
        txt_bin = f_bin(:,8)';
        txt = binary_to_ascii(txt_bin);
        try
            jTextArea = javaObjectEDT('javax.swing.JTextArea',txt);
            head.Parent.Children(7) = javacomponent(jTextArea,[15,220,200,200]);
        catch
            % maybe i missed something here.
        end
    end
%% Hide function
    function hide(~,~)
        fig = figure("Name","HW1_Q3 : "+img.Name); % create a new figure
        add_help_button(fig,"About HW1_Q3","Every image pixel contains 8-bit number ; the first image is the first bit for each pixel , and if the image is rgb one then it''s the first bit for the red ,green and blue 8-bit numbers  , then  the second image contains the 2''nd bit incrementally with the first one (contains 1''st & 2''nd) , and each image contains the next bit incrementally.");
        
        x = 2; % number of images on x axsis
        y = 4; % number of images on y axsis
        
        % create @shaping handle
        if(img.Type=="truecolor") % shaping for colored image
            r_unit_size = 1:img.Size;
            g_unit_size = 1+img.Size:2*img.Size;
            b_unit_size = 1+2*img.Size:3*img.Size;
            
            shaping = @(f_dec) reshape([f_dec(r_unit_size),f_dec(g_unit_size),f_dec(b_unit_size)] ,img.Width,img.Height,3);
        else    % shaping for not colored (gray) image
            shaping = @(f_dec)reshape(f_dec,img.Width,img.Height);
        end
        
        f_bin = dec2bin(img.Value);
        f_bin_flipped = fliplr(f_bin);
        
        for i=1:8
            subplot(x,y,i);
            f_i_flipped = f_bin_flipped(:,1:i);
            f_i = fliplr(f_i_flipped);
            f_dec = bin2dec(f_i) * ((2^(9-i))-1);
            
            
            f_final = shaping(f_dec);
            
            imshow(uint8(f_final));
            title([num2str(i) '-bit']);
        end
    end
%% Utils
    function add_help_button(fig,title,content)
        help_box = uicontrol("String","?");
        function render_help(~,~)
            pos = get(fig, 'Position');
            set(help_box,"Position",[pos(3)-25,pos(4)-25,25,25]);
        end
        function show_help(~,~)
            help_fig = figure("resize","off","position",[200,200,600,300]);
            help_label = javaObjectEDT('javax.swing.JLabel','<html><font size="5">&nbsp;&nbsp;&nbsp;&nbsp;'+title+'<br><hr><br>&nbsp;'+content+'</html>');
            javacomponent(help_label,[10,10,help_fig.Position(3)-10,help_fig.Position(4)-20]);
            help_label.setVerticalAlignment(1);
        end
        render_help();
        set(help_box,"Callback",@show_help);
        fig.SizeChangedFcn = @render_help;
    end
    function [ascii_txt] = binary_to_ascii(binary_txt)
        number_of_possible_chars = uint64(length(binary_txt)/8);
        binary_txt = binary_txt(1:number_of_possible_chars);
        ascii_txt = char(bin2dec(reshape(binary_txt,[],8)));
        if ascii_txt(1)==bin2dec('00000010')
            [~,i]=ismember(bin2dec('00000011'),ascii_txt,'R2012a');
            if i~=0
                ascii_txt = ascii_txt(1:i);
                return;
            end
        end
        ascii_txt = 'There is no Hidden Text in this image!';
    end
    function [binary_txt] = ascii_to_binary(ascii_txt)
        % TODO check this
        binary_txt(1) = '00000010';
        binary_txt(2:1+length(ascii_txt)*8) = char(dec2bin(ascii_txt));
        binary_txt(end) = '00000011';
    end
end