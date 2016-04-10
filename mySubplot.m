function mySubplot(figureHandle, subplotWidth, subplotHeight, subplotPos, img, imgTitle, newMap)
% MYSUBPLOT creates a matrix of subplots, each with a custom colormap    
    changeMap = sprintf('colormap %s', newMap);
    figure(figureHandle)	
    subplot(subplotWidth, subplotHeight, subplotPos)
	imagesc(img)
    eval(changeMap);
    freezeColors
	pbaspect([size(img,2),size(img,1),1]);
	title(imgTitle)
    axis off;
end