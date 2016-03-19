--[[
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 ]]

local CSS_DIRECTION_INHERIT = "inherit";
local CSS_DIRECTION_LTR = "ltr";
local CSS_DIRECTION_RTL = "rtl";

local CSS_FLEX_DIRECTION_ROW = "row";
local CSS_FLEX_DIRECTION_ROW_REVERSE = "row-reverse";
local CSS_FLEX_DIRECTION_COLUMN = "column";
local CSS_FLEX_DIRECTION_COLUMN_REVERSE = "column-reverse";

local CSS_JUSTIFY_FLEX_START = "flex-start";
local CSS_JUSTIFY_CENTER = "center";
local CSS_JUSTIFY_FLEX_END = "flex-end";
local CSS_JUSTIFY_SPACE_BETWEEN = "space-between";
local CSS_JUSTIFY_SPACE_AROUND = "space-around";

local CSS_ALIGN_FLEX_START = "flex-start";
local CSS_ALIGN_CENTER = "center";
local CSS_ALIGN_FLEX_END = "flex-end";
local CSS_ALIGN_STRETCH = "stretch";

local CSS_POSITION_RELATIVE = "relative";
local CSS_POSITION_ABSOLUTE = "absolute";

local leading = {
  ["row"] = "left",
  ["row-reverse"] = "right",
  ["column"] = "top",
  ["column-reverse"] = "bottom"
};
local trailing = {
  ["row"] = "right",
  ["row-reverse"] = "left",
  ["column"] = "bottom",
  ["column-reverse"] = "top"
};
local pos = {
  ["row"] = "left",
  ["row-reverse"] = "right",
  ["column"] = "top",
  ["column-reverse"] = "bottom"
};
local dim = {
  ["row"] = "width",
  ["row-reverse"] = "width",
  ["column"] = "height",
  ["column-reverse"] = "height"
};

-- When transpiled to Java / C the node type has layout, children and style
-- properties. For the JavaScript version this function adds these properties
-- if they don"t already exist.
function fillNodes(node)
  if not node.layout or node.isDirty then
    node.layout = {
      width = nil,
      height = nil,
      top = 0,
      left = 0,
      right = 0,
      bottom = 0
    };
  end

  if not node.style then
    node.style = {};
  end

  if not node.children then
    node.children = {};
  end

  for _, child in ipairs(node.children) do
    fillNodes(child)
  end

  return node;
end

function isUndefined(value)
  return value == nil;
end

function isRowDirection(flexDirection)
  return flexDirection == CSS_FLEX_DIRECTION_ROW or
         flexDirection == CSS_FLEX_DIRECTION_ROW_REVERSE;
end

function isColumnDirection(flexDirection)
  return flexDirection == CSS_FLEX_DIRECTION_COLUMN or
         flexDirection == CSS_FLEX_DIRECTION_COLUMN_REVERSE;
end

function getLeadingMargin(node, axis)
  if node.style.marginStart ~= nil and isRowDirection(axis) then
    return node.style.marginStart;
  end

  local value = nil;
      if axis == "row"            then value = node.style.marginLeft
  elseif axis == "row-reverse"    then value = node.style.marginRight
  elseif axis == "column"         then value = node.style.marginTop
  elseif axis == "column-reverse" then value = node.style.marginBottom
  end

  if value ~= nil then
    return value;
  end

  if node.style.margin ~= nil then
    return node.style.margin;
  end

  return 0;
end

function getTrailingMargin(node, axis)
  if node.style.marginEnd ~= nil and isRowDirection(axis) then
    return node.style.marginEnd;
  end

  local value = nil;
      if axis == "row"            then value = node.style.marginRight
  elseif axis == "row-reverse"    then value = node.style.marginLeft
  elseif axis == "column"         then value = node.style.marginBottom
  elseif axis == "column-reverse" then value = node.style.marginTop
  end

  if value ~= nil then
    return value;
  end

  if node.style.margin ~= nil then
    return node.style.margin;
  end

  return 0;
end

function getLeadingPadding(node, axis)
  if node.style.paddingStart ~= nil and node.style.paddingStart >= 0
      and isRowDirection(axis) then
    return node.style.paddingStart;
  end

  local value = nil;
      if axis == "row"            then value = node.style.paddingLeft
  elseif axis == "row-reverse"    then value = node.style.paddingRight
  elseif axis == "column"         then value = node.style.paddingTop
  elseif axis == "column-reverse" then value = node.style.paddingBottom
  end

  if value ~= nil and value >= 0 then
    return value;
  end

  if node.style.padding ~= nil and node.style.padding >= 0 then
    return node.style.padding;
  end

  return 0;
end

function getTrailingPadding(node, axis)
  if node.style.paddingEnd ~= nil and node.style.paddingEnd >= 0
      and isRowDirection(axis) then
    return node.style.paddingEnd;
  end

  local value = nil;
      if axis == "row"            then value = node.style.paddingRight
  elseif axis == "row-reverse"    then value = node.style.paddingLeft
  elseif axis == "column"         then value = node.style.paddingBottom
  elseif axis == "column-reverse" then value = node.style.paddingTop
  end

  if value ~= nil and value >= 0 then
    return value;
  end

  if node.style.padding ~= nil and node.style.padding >= 0 then
    return node.style.padding;
  end

  return 0;
end

function getLeadingBorder(node, axis)
  if node.style.borderStartWidth ~= nil and node.style.borderStartWidth >= 0
      and isRowDirection(axis) then
    return node.style.borderStartWidth;
  end

  local value = nil;
      if axis == "row"            then value = node.style.borderLeftWidth
  elseif axis == "row-reverse"    then value = node.style.borderRightWidth
  elseif axis == "column"         then value = node.style.borderTopWidth
  elseif axis == "column-reverse" then value = node.style.borderBottomWidth
  end

  if value ~= nil and value >= 0 then
    return value;
  end

  if node.style.borderWidth ~= nil and node.style.borderWidth >= 0 then
    return node.style.borderWidth;
  end

  return 0;
end

function getTrailingBorder(node, axis)
  if node.style.borderEndWidth ~= nil and node.style.borderEndWidth >= 0
      and isRowDirection(axis) then
    return node.style.borderEndWidth;
  end

  local value = nil;
      if axis == "row"            then value = node.style.borderRightWidth
  elseif axis == "row-reverse"    then value = node.style.borderLeftWidth
  elseif axis == "column"         then value = node.style.borderBottomWidth
  elseif axis == "column-reverse" then value = node.style.borderTopWidth
  end

  if value ~= nil and value >= 0 then
    return value;
  end

  if node.style.borderWidth ~= nil and node.style.borderWidth >= 0 then
    return node.style.borderWidth;
  end

  return 0;
end

function getLeadingPaddingAndBorder(node, axis)
  return getLeadingPadding(node, axis) + getLeadingBorder(node, axis);
end

function getTrailingPaddingAndBorder(node, axis)
  return getTrailingPadding(node, axis) + getTrailingBorder(node, axis);
end

function getBorderAxis(node, axis)
  return getLeadingBorder(node, axis) + getTrailingBorder(node, axis);
end

function getMarginAxis(node, axis)
  return getLeadingMargin(node, axis) + getTrailingMargin(node, axis);
end

function getPaddingAndBorderAxis(node, axis)
  return getLeadingPaddingAndBorder(node, axis) +
      getTrailingPaddingAndBorder(node, axis);
end

function getJustifyContent(node)
  if node.style.justifyContent then
    return node.style.justifyContent;
  end
  return "flex-start";
end

function getAlignContent(node)
  if node.style.alignContent then
    return node.style.alignContent;
  end
  return "flex-start";
end

function getAlignItem(node, child)
  if child.style.alignSelf then
    return child.style.alignSelf;
  end
  if node.style.alignItems then
    return node.style.alignItems;
  end
  return "stretch";
end

function resolveAxis(axis, direction)
  if direction == CSS_DIRECTION_RTL then
    if axis == CSS_FLEX_DIRECTION_ROW then
      return CSS_FLEX_DIRECTION_ROW_REVERSE;
    elseif axis == CSS_FLEX_DIRECTION_ROW_REVERSE then
      return CSS_FLEX_DIRECTION_ROW;
    end
  end

  return axis;
end

function resolveDirection(node, parentDirection)
  local direction;
  if node.style.direction then
    direction = node.style.direction;
  else
    direction = CSS_DIRECTION_INHERIT;
  end

  if direction == CSS_DIRECTION_INHERIT then
    -- direction = (parentDirection == nil ? CSS_DIRECTION_LTR : parentDirection);
    if parentDirection == nil then
      direction = CSS_DIRECTION_LTR
    else
      direction = parentDirection
    end
  end

  return direction;
end

function getFlexDirection(node)
  if node.style.flexDirection then
    return node.style.flexDirection;
  end
  return CSS_FLEX_DIRECTION_COLUMN;
end

function getCrossFlexDirection(flexDirection, direction)
  if isColumnDirection(flexDirection) then
    return resolveAxis(CSS_FLEX_DIRECTION_ROW, direction);
  else
    return CSS_FLEX_DIRECTION_COLUMN;
  end
end

function getPositionType(node)
  if node.style.position then
    return node.style.position;
  end
  return "relative";
end

function isFlex(node)
  return (
    getPositionType(node) == CSS_POSITION_RELATIVE and
    node.style.flex ~= nil and
    node.style.flex > 0
  );
end

function isFlexWrap(node)
  return node.style.flexWrap == "wrap";
end

function getDimWithMargin(node, axis)
  return node.layout[dim[axis]] + getMarginAxis(node, axis);
end

function isDimDefined(node, axis)
  return node.style[dim[axis]] ~= nil and node.style[dim[axis]] >= 0;
end

function isPosDefined(node, pos)
  return node.style[pos] ~= nil;
end

function isMeasureDefined(node)
  return node.style.measure ~= nil;
end

function getPosition(node, pos)
  if node.style[pos] ~= nil then
    return node.style[pos];
  end
  return 0;
end

function boundAxis(node, axis, value)
  local min = ({
    ["row"] = node.style.minWidth,
    ["row-reverse"] = node.style.minWidth,
    ["column"] = node.style.minHeight,
    ["column-reverse"] = node.style.minHeight
  })[axis];

  local max = ({
    ["row"] = node.style.maxWidth,
    ["row-reverse"] = node.style.maxWidth,
    ["column"] = node.style.maxHeight,
    ["column-reverse"] = node.style.maxHeight
  })[axis];

  local boundValue = value;
  if max ~= nil and max >= 0 and boundValue > max then
    boundValue = max;
  end
  if min ~= nil and min >= 0 and boundValue < min then
    boundValue = min;
  end
  return boundValue;
end

function fmaxf(a, b)
  if a > b then
    return a;
  end
  return b;
end

-- When the user specifically sets a value for width or height
function setDimensionFromStyle(node, axis)
  -- The parent already computed us a width or height. We just skip it
  if node.layout[dim[axis]] ~= nil then
    return;
  end
  -- We only run if there"s a width or height defined
  if not isDimDefined(node, axis) then
    return;
  end

  -- The dimensions can never be smaller than the padding and border
  node.layout[dim[axis]] = fmaxf(
    boundAxis(node, axis, node.style[dim[axis]]),
    getPaddingAndBorderAxis(node, axis)
  );
end

function setTrailingPosition(node, child, axis)
  child.layout[trailing[axis]] = node.layout[dim[axis]] -
      child.layout[dim[axis]] - child.layout[pos[axis]];
end

-- If both left and right are defined, then use left. Otherwise return
-- +left or -right depending on which is defined.
function getRelativePosition(node, axis)
  if node.style[leading[axis]] ~= nil then
    return getPosition(node, leading[axis]);
  end
  return -getPosition(node, trailing[axis]);
end

function layoutNodeImpl(node, parentMaxWidth, --[[css_direction_t]]parentDirection)
  local--[[css_direction_t]] direction = resolveDirection(node, parentDirection);
  local--[[(c)not css_flex_direction_t]]--[[(java)not int]] mainAxis = resolveAxis(getFlexDirection(node), direction);
  local--[[(c)not css_flex_direction_t]]--[[(java)not int]] crossAxis = getCrossFlexDirection(mainAxis, direction);
  local--[[(c)not css_flex_direction_t]]--[[(java)not int]] resolvedRowAxis = resolveAxis(CSS_FLEX_DIRECTION_ROW, direction);

  -- Handle width and height style attributes
  setDimensionFromStyle(node, mainAxis);
  setDimensionFromStyle(node, crossAxis);

  -- Set the resolved resolution in the node"s layout
  node.layout.direction = direction;

  -- The position is set by the parent, but we need to complete it with a
  -- delta composed of the margin and left/top/right/bottom
  node.layout[leading[mainAxis]] = node.layout[leading[mainAxis]] +
    getLeadingMargin(node, mainAxis) +
    getRelativePosition(node, mainAxis);
  node.layout[trailing[mainAxis]] = node.layout[trailing[mainAxis]] +
    getTrailingMargin(node, mainAxis) +
    getRelativePosition(node, mainAxis);
  node.layout[leading[crossAxis]] = node.layout[leading[crossAxis]] +
    getLeadingMargin(node, crossAxis) +
    getRelativePosition(node, crossAxis);
  node.layout[trailing[crossAxis]] = node.layout[trailing[crossAxis]] +
    getTrailingMargin(node, crossAxis) +
    getRelativePosition(node, crossAxis);

  -- Inline immutable values from the target node to avoid excessive method
  -- invocations during the layout calculation.
  local--[[int]] childCount = #node.children;
  local--[[float]] paddingAndBorderAxisResolvedRow = getPaddingAndBorderAxis(node, resolvedRowAxis);

  if isMeasureDefined(node) then
    local--[[bool]] isResolvedRowDimDefined = not isUndefined(node.layout[dim[resolvedRowAxis]]);

    local--[[float]] width;
    if isDimDefined(node, resolvedRowAxis) then
      width = node.style.width;
    elseif isResolvedRowDimDefined then
      width = node.layout[dim[resolvedRowAxis]];
    else
      width = parentMaxWidth -
        getMarginAxis(node, resolvedRowAxis);
    end
    width = width - paddingAndBorderAxisResolvedRow;

    -- We only need to give a dimension for the text if we haven"t got any
    -- for it computed yet. It can either be from the style attribute or because
    -- the element is flexible.
    local--[[bool]] isRowUndefined = not isDimDefined(node, resolvedRowAxis) and not isResolvedRowDimDefined;
    local--[[bool]] isColumnUndefined = not isDimDefined(node, CSS_FLEX_DIRECTION_COLUMN) and
      isUndefined(node.layout[dim[CSS_FLEX_DIRECTION_COLUMN]]);

    -- Let"s not measure the text if we already know both dimensions
    if isRowUndefined or isColumnUndefined then
      local--[[css_dim_t]] measureDim = node.style.measure(
        --[[(c)not node->context,]]
        --[[(java)not layoutContext.measureOutput,]]
        width
      );
      if isRowUndefined then
        node.layout.width = measureDim.width +
          paddingAndBorderAxisResolvedRow;
      end
      if isColumnUndefined then
        node.layout.height = measureDim.height +
          getPaddingAndBorderAxis(node, CSS_FLEX_DIRECTION_COLUMN);
      end
    end
    if childCount == 0 then
      return;
    end
  end

  local--[[bool]] isNodeFlexWrap = isFlexWrap(node);

  local--[[css_justify_t]] justifyContent = getJustifyContent(node);

  local--[[float]] leadingPaddingAndBorderMain = getLeadingPaddingAndBorder(node, mainAxis);
  local--[[float]] leadingPaddingAndBorderCross = getLeadingPaddingAndBorder(node, crossAxis);
  local--[[float]] paddingAndBorderAxisMain = getPaddingAndBorderAxis(node, mainAxis);
  local--[[float]] paddingAndBorderAxisCross = getPaddingAndBorderAxis(node, crossAxis);

  local--[[bool]] isMainDimDefined = not isUndefined(node.layout[dim[mainAxis]]);
  local--[[bool]] isCrossDimDefined = not isUndefined(node.layout[dim[crossAxis]]);
  local--[[bool]] isMainRowDirection = isRowDirection(mainAxis);

  local--[[int]] i;
  local--[[int]] ii;
  local--[[css_node_t*]] child;
  local--[[(c)not css_flex_direction_t]]--[[(java)not int]] axis;

  local--[[css_node_t*]] firstAbsoluteChild = nil;
  local--[[css_node_t*]] currentAbsoluteChild = nil;

  local--[[float]] definedMainDim;
  if isMainDimDefined then
    definedMainDim = node.layout[dim[mainAxis]] - paddingAndBorderAxisMain;
  end

  -- We want to execute the next two loops one per line with flex-wrap
  local--[[int]] startLine = 0;
  local--[[int]] endLine = 0;
  -- local--[[int]] nextOffset = 0;
  local--[[int]] alreadyComputedNextLayout = 0;
  -- We aggregate the total dimensions of the container in those two variables
  local--[[float]] linesCrossDim = 0;
  local--[[float]] linesMainDim = 0;
  local--[[int]] linesCount = 0;
  while endLine < childCount do
    -- <Loop A> Layout non flexible children and count children by type

    -- mainContentDim is accumulation of the dimensions and margin of all the
    -- non flexible children. This will be used in order to either set the
    -- dimensions of the node if none already exist, or to compute the
    -- remaining space left for the flexible children.
    local--[[float]] mainContentDim = 0;

    -- There are three kind of children, non flexible, flexible and absolute.
    -- We need to know how many there are in order to distribute the space.
    local--[[int]] flexibleChildrenCount = 0;
    local--[[float]] totalFlexible = 0;
    local--[[int]] nonFlexibleChildrenCount = 0;

    -- Use the line loop to position children in the main axis for as long
    -- as they are using a simple stacking behaviour. Children that are
    -- immediately stacked in the initial loop will not be touched again
    -- in <Loop C>.
    local--[[bool]] isSimpleStackMain =
        (isMainDimDefined and justifyContent == CSS_JUSTIFY_FLEX_START) or
        (not isMainDimDefined and justifyContent ~= CSS_JUSTIFY_CENTER);
    -- local--[[int]] firstComplexMain = (isSimpleStackMain ? childCount : startLine);
    local --[[int]] firstComplexMain
    if isSimpleStackMain then
      firstComplexMain = childCount
    else
      firstComplexMain = startLine
    end

    -- Use the initial line loop to position children in the cross axis for
    -- as long as they are relatively positioned with alignment STRETCH or
    -- FLEX_START. Children that are immediately stacked in the initial loop
    -- will not be touched again in <Loop D>.
    local--[[bool]] isSimpleStackCross = true;
    local--[[int]] firstComplexCross = childCount;

    local--[[css_node_t*]] firstFlexChild = nil;
    local--[[css_node_t*]] currentFlexChild = nil;

    local--[[float]] mainDim = leadingPaddingAndBorderMain;
    local--[[float]] crossDim = 0;

    local--[[float]] maxWidth;
    -- for (i = startLine; i < childCount; ++i) {
    i = startLine
    while i < childCount do
      child = node.children[i + 1] --[[ TODO: fix indices ]];
      child.lineIndex = linesCount;

      child.nextAbsoluteChild = nil;
      child.nextFlexChild = nil;

      local--[[css_align_t]] alignItem = getAlignItem(node, child);

      -- Pre-fill cross axis dimensions when the child is using stretch before
      -- we call the recursive layout pass
      if alignItem == CSS_ALIGN_STRETCH and
          getPositionType(child) == CSS_POSITION_RELATIVE and
          isCrossDimDefined and
          not isDimDefined(child, crossAxis) then
        child.layout[dim[crossAxis]] = fmaxf(
          boundAxis(child, crossAxis, node.layout[dim[crossAxis]] -
            paddingAndBorderAxisCross - getMarginAxis(child, crossAxis)),
          -- You never want to go smaller than padding
          getPaddingAndBorderAxis(child, crossAxis)
        );
      elseif getPositionType(child) == CSS_POSITION_ABSOLUTE then
        -- Store a private linked list of absolutely positioned children
        -- so that we can efficiently traverse them later.
        if firstAbsoluteChild == nil then
          firstAbsoluteChild = child;
        end
        if currentAbsoluteChild ~= nil then
          currentAbsoluteChild.nextAbsoluteChild = child;
        end
        currentAbsoluteChild = child;

        -- Pre-fill dimensions when using absolute position and both offsets for the axis are defined (either both
        -- left and right or top and bottom).
        -- for (ii = 0; ii < 2; ii++) {
        ii = 0
        while ii < 2 do
          -- axis = (ii ~= 0) ? CSS_FLEX_DIRECTION_ROW : CSS_FLEX_DIRECTION_COLUMN;
          if ii ~= 0 then
            axis = CSS_FLEX_DIRECTION_ROW
          else
            axis = CSS_FLEX_DIRECTION_COLUMN
          end
          if not isUndefined(node.layout[dim[axis]]) and
              not isDimDefined(child, axis) and
              isPosDefined(child, leading[axis]) and
              isPosDefined(child, trailing[axis]) then
            child.layout[dim[axis]] = fmaxf(
              boundAxis(child, axis, node.layout[dim[axis]] -
                getPaddingAndBorderAxis(node, axis) -
                getMarginAxis(child, axis) -
                getPosition(child, leading[axis]) -
                getPosition(child, trailing[axis])),
              -- You never want to go smaller than padding
              getPaddingAndBorderAxis(child, axis)
            );
          end

          ii = ii + 1
        end
      end

      local--[[float]] nextContentDim = 0;

      -- It only makes sense to consider a child flexible if we have a computed
      -- dimension for the node.
      if isMainDimDefined and isFlex(child) then
        flexibleChildrenCount = flexibleChildrenCount + 1;
        totalFlexible = totalFlexible + child.style.flex;

        -- Store a private linked list of flexible children so that we can
        -- efficiently traverse them later.
        if firstFlexChild == nil then
          firstFlexChild = child;
        end
        if currentFlexChild ~= nil then
          currentFlexChild.nextFlexChild = child;
        end
        currentFlexChild = child;

        -- Even if we don"t know its exact size yet, we already know the padding,
        -- border and margin. We"ll use this partial information, which represents
        -- the smallest possible size for the child, to compute the remaining
        -- available space.
        nextContentDim = getPaddingAndBorderAxis(child, mainAxis) +
          getMarginAxis(child, mainAxis);

      else
        maxWidth = nil;
        if not isMainRowDirection then
          if isDimDefined(node, resolvedRowAxis) then
            maxWidth = node.layout[dim[resolvedRowAxis]] -
              paddingAndBorderAxisResolvedRow;
          else
            maxWidth = parentMaxWidth -
              getMarginAxis(node, resolvedRowAxis) -
              paddingAndBorderAxisResolvedRow;
          end
        end

        -- This is the main recursive call. We layout non flexible children.
        if alreadyComputedNextLayout == 0 then
          layoutNode(--[[(java)not layoutContext, ]]child, maxWidth, direction);
        end

        -- Absolute positioned elements do not take part of the layout, so we
        -- don"t use them to compute mainContentDim
        if getPositionType(child) == CSS_POSITION_RELATIVE then
          nonFlexibleChildrenCount = nonFlexibleChildrenCount + 1;
          -- At this point we know the final size and margin of the element.
          nextContentDim = getDimWithMargin(child, mainAxis);
        end
      end

      -- The element we are about to add would make us go to the next line
      if isNodeFlexWrap and
          isMainDimDefined and
          mainContentDim + nextContentDim > definedMainDim and
          -- If there"s only one element, then it"s bigger than the content
          -- and needs its own line
          i ~= startLine then
        nonFlexibleChildrenCount = nonFlexibleChildrenCount - 1
        alreadyComputedNextLayout = 1;
        break;
      end

      -- Disable simple stacking in the main axis for the current line as
      -- we found a non-trivial child. The remaining children will be laid out
      -- in <Loop C>.
      if isSimpleStackMain and
          (getPositionType(child) ~= CSS_POSITION_RELATIVE or isFlex(child)) then
        isSimpleStackMain = false;
        firstComplexMain = i;
      end

      -- Disable simple stacking in the cross axis for the current line as
      -- we found a non-trivial child. The remaining children will be laid out
      -- in <Loop D>.
      if isSimpleStackCross and
          (getPositionType(child) ~= CSS_POSITION_RELATIVE or
              (alignItem ~= CSS_ALIGN_STRETCH and alignItem ~= CSS_ALIGN_FLEX_START) or
              isUndefined(child.layout[dim[crossAxis]])) then
        isSimpleStackCross = false;
        firstComplexCross = i;
      end

      if isSimpleStackMain then
        child.layout[pos[mainAxis]] = child.layout[pos[mainAxis]] + mainDim;
        if isMainDimDefined then
          setTrailingPosition(node, child, mainAxis);
        end

        mainDim = mainDim + getDimWithMargin(child, mainAxis);
        crossDim = fmaxf(crossDim, boundAxis(child, crossAxis, getDimWithMargin(child, crossAxis)));
      end

      if isSimpleStackCross then
        child.layout[pos[crossAxis]] = child.layout[pos[crossAxis]] + linesCrossDim + leadingPaddingAndBorderCross;
        if isCrossDimDefined then
          setTrailingPosition(node, child, crossAxis);
        end
      end

      alreadyComputedNextLayout = 0;
      mainContentDim = mainContentDim + nextContentDim;
      endLine = i + 1;

      i = i + 1
    end

    -- <Loop B> Layout flexible children and allocate empty space

    -- In order to position the elements in the main axis, we have two
    -- controls. The space between the beginning and the first element
    -- and the space between each two elements.
    local--[[float]] leadingMainDim = 0;
    local--[[float]] betweenMainDim = 0;

    -- The remaining available space that needs to be allocated
    local--[[float]] remainingMainDim = 0;
    if isMainDimDefined then
      remainingMainDim = definedMainDim - mainContentDim;
    else
      remainingMainDim = fmaxf(mainContentDim, 0) - mainContentDim;
    end

    -- If there are flexible children in the mix, they are going to fill the
    -- remaining space
    if flexibleChildrenCount ~= 0 then
      local--[[float]] flexibleMainDim = remainingMainDim / totalFlexible;
      local--[[float]] baseMainDim;
      local--[[float]] boundMainDim;

      -- If the flex share of remaining space doesn"t meet min/max bounds,
      -- remove this child from flex calculations.
      currentFlexChild = firstFlexChild;
      while currentFlexChild ~= nil do
        baseMainDim = flexibleMainDim * currentFlexChild.style.flex +
            getPaddingAndBorderAxis(currentFlexChild, mainAxis);
        boundMainDim = boundAxis(currentFlexChild, mainAxis, baseMainDim);

        if baseMainDim ~= boundMainDim then
          remainingMainDim = remainingMainDim - boundMainDim;
          totalFlexible = totalFlexible - currentFlexChild.style.flex;
        end

        currentFlexChild = currentFlexChild.nextFlexChild;
      end
      flexibleMainDim = remainingMainDim / totalFlexible;

      -- The non flexible children can overflow the container, in this case
      -- we should just assume that there is no space available.
      if flexibleMainDim < 0 then
        flexibleMainDim = 0;
      end

      currentFlexChild = firstFlexChild;
      while currentFlexChild ~= nil do
        -- At this point we know the final size of the element in the main
        -- dimension
        currentFlexChild.layout[dim[mainAxis]] = boundAxis(currentFlexChild, mainAxis,
          flexibleMainDim * currentFlexChild.style.flex +
              getPaddingAndBorderAxis(currentFlexChild, mainAxis)
        );

        maxWidth = nil;
        if isDimDefined(node, resolvedRowAxis) then
          maxWidth = node.layout[dim[resolvedRowAxis]] -
            paddingAndBorderAxisResolvedRow;
        elseif not isMainRowDirection then
          maxWidth = parentMaxWidth -
            getMarginAxis(node, resolvedRowAxis) -
            paddingAndBorderAxisResolvedRow;
        end

        -- And we recursively call the layout algorithm for this child
        layoutNode(--[[(java)not layoutContext, ]]currentFlexChild, maxWidth, direction);

        child = currentFlexChild;
        currentFlexChild = currentFlexChild.nextFlexChild;
        child.nextFlexChild = nil;
      end

    -- We use justifyContent to figure out how to allocate the remaining
    -- space available
    elseif justifyContent ~= CSS_JUSTIFY_FLEX_START then
      if justifyContent == CSS_JUSTIFY_CENTER then
        leadingMainDim = remainingMainDim / 2;
      elseif justifyContent == CSS_JUSTIFY_FLEX_END then
        leadingMainDim = remainingMainDim;
      elseif justifyContent == CSS_JUSTIFY_SPACE_BETWEEN then
        remainingMainDim = fmaxf(remainingMainDim, 0);
        if flexibleChildrenCount + nonFlexibleChildrenCount - 1 ~= 0 then
          betweenMainDim = remainingMainDim /
            (flexibleChildrenCount + nonFlexibleChildrenCount - 1);
        else
          betweenMainDim = 0;
        end
      elseif justifyContent == CSS_JUSTIFY_SPACE_AROUND then
        -- Space on the edges is half of the space between elements
        betweenMainDim = remainingMainDim /
          (flexibleChildrenCount + nonFlexibleChildrenCount);
        leadingMainDim = betweenMainDim / 2;
      end
    end

    -- <Loop C> Position elements in the main axis and compute dimensions

    -- At this point, all the children have their dimensions set. We need to
    -- find their position. In order to do that, we accumulate data in
    -- variables that are also useful to compute the total dimensions of the
    -- containernot
    mainDim = mainDim + leadingMainDim;

    -- for (i = firstComplexMain; i < endLine; ++i) {
    i = firstComplexMain
    while i < endLine do
      child = node.children[i + 1] --[[ TODO: fix indices ]];

      if getPositionType(child) == CSS_POSITION_ABSOLUTE and
          isPosDefined(child, leading[mainAxis]) then
        -- In case the child is position absolute and has left/top being
        -- defined, we override the position to whatever the user said
        -- (and margin/border).
        child.layout[pos[mainAxis]] = getPosition(child, leading[mainAxis]) +
          getLeadingBorder(node, mainAxis) +
          getLeadingMargin(child, mainAxis);
      else
        -- If the child is position absolute (without top/left) or relative,
        -- we put it at the current accumulated offset.
        child.layout[pos[mainAxis]] = child.layout[pos[mainAxis]] + mainDim;

        -- Define the trailing position accordingly.
        if isMainDimDefined then
          setTrailingPosition(node, child, mainAxis);
        end

        -- Now that we placed the element, we need to update the variables
        -- We only need to do that for relative elements. Absolute elements
        -- do not take part in that phase.
        if getPositionType(child) == CSS_POSITION_RELATIVE then
          -- The main dimension is the sum of all the elements dimension plus
          -- the spacing.
          mainDim = mainDim + betweenMainDim + getDimWithMargin(child, mainAxis);
          -- The cross dimension is the max of the elements dimension since there
          -- can only be one element in that cross dimension.
          crossDim = fmaxf(crossDim, boundAxis(child, crossAxis, getDimWithMargin(child, crossAxis)));
        end
      end

      i = i + 1
    end

    local--[[float]] containerCrossAxis = node.layout[dim[crossAxis]];
    if not isCrossDimDefined then
      containerCrossAxis = fmaxf(
        -- For the cross dim, we add both sides at the end because the value
        -- is aggregate via a max function. Intermediate negative values
        -- can mess this computation otherwise
        boundAxis(node, crossAxis, crossDim + paddingAndBorderAxisCross),
        paddingAndBorderAxisCross
      );
    end

    -- <Loop D> Position elements in the cross axis
    -- for (i = firstComplexCross; i < endLine; ++i)
    i = firstComplexCross
    while i < endLine do
      child = node.children[i + 1] --[[ TODO: fix indices ]];

      if getPositionType(child) == CSS_POSITION_ABSOLUTE and
          isPosDefined(child, leading[crossAxis]) then
        -- In case the child is absolutely positionned and has a
        -- top/left/bottom/right being set, we override all the previously
        -- computed positions to set it correctly.
        child.layout[pos[crossAxis]] = getPosition(child, leading[crossAxis]) +
          getLeadingBorder(node, crossAxis) +
          getLeadingMargin(child, crossAxis);

      else
        local--[[float]] leadingCrossDim = leadingPaddingAndBorderCross;

        -- For a relative children, we"re either using alignItems (parent) or
        -- alignSelf (child) in order to determine the position in the cross axis
        if getPositionType(child) == CSS_POSITION_RELATIVE then
          --[[eslint-disable ]]
          -- This variable is intentionally re-defined as the code is transpiled to a block scope language
          local--[[css_align_t]] alignItem = getAlignItem(node, child);
          --[[eslint-enable ]]
          if alignItem == CSS_ALIGN_STRETCH then
            -- You can only stretch if the dimension has not already been set
            -- previously.
            if isUndefined(child.layout[dim[crossAxis]]) then
              child.layout[dim[crossAxis]] = fmaxf(
                boundAxis(child, crossAxis, containerCrossAxis -
                  paddingAndBorderAxisCross - getMarginAxis(child, crossAxis)),
                -- You never want to go smaller than padding
                getPaddingAndBorderAxis(child, crossAxis)
              );
            end
          elseif alignItem ~= CSS_ALIGN_FLEX_START then
            -- The remaining space between the parent dimensions+padding and child
            -- dimensions+margin.
            local--[[float]] remainingCrossDim = containerCrossAxis -
              paddingAndBorderAxisCross - getDimWithMargin(child, crossAxis);

            if alignItem == CSS_ALIGN_CENTER then
              leadingCrossDim = leadingCrossDim + remainingCrossDim / 2;
            else -- CSS_ALIGN_FLEX_END
              leadingCrossDim = leadingCrossDim + remainingCrossDim;
            end
          end
        end

        -- And we apply the position
        child.layout[pos[crossAxis]] = child.layout[pos[crossAxis]] + linesCrossDim + leadingCrossDim;

        -- Define the trailing position accordingly.
        if isCrossDimDefined then
          setTrailingPosition(node, child, crossAxis);
        end
      end

      i = i + 1
    end

    linesCrossDim = linesCrossDim + crossDim;
    linesMainDim = fmaxf(linesMainDim, mainDim);
    linesCount = linesCount + 1;
    startLine = endLine;
  end

  -- <Loop E>
  --
  -- Note(prenaux): More than one line, we need to layout the crossAxis
  -- according to alignContent.
  --
  -- Note that we could probably remove <Loop D> and handle the one line case
  -- here too, but for the moment this is safer since it won"t interfere with
  -- previously working code.
  --
  -- See specs:
  -- http:--www.w3.org/TR/2012/CR-css3-flexbox-20120918/#layout-algorithm
  -- section 9.4
  --
  if linesCount > 1 and isCrossDimDefined then
    local--[[float]] nodeCrossAxisInnerSize = node.layout[dim[crossAxis]] -
        paddingAndBorderAxisCross;
    local--[[float]] remainingAlignContentDim = nodeCrossAxisInnerSize - linesCrossDim;

    local--[[float]] crossDimLead = 0;
    local--[[float]] currentLead = leadingPaddingAndBorderCross;

    local--[[css_align_t]] alignContent = getAlignContent(node);
    if alignContent == CSS_ALIGN_FLEX_END then
      currentLead = currentLead + remainingAlignContentDim;
    elseif alignContent == CSS_ALIGN_CENTER then
      currentLead = currentLead + remainingAlignContentDim / 2;
    elseif alignContent == CSS_ALIGN_STRETCH then
      if nodeCrossAxisInnerSize > linesCrossDim then
        crossDimLead = (remainingAlignContentDim / linesCount);
      end
    end

    local--[[int]] endIndex = 0;
    -- for (i = 0; i < linesCount; ++i) {
    i = 0
    while i < linesCount do
      local--[[int]] startIndex = endIndex;

      -- compute the line"s height and find the endIndex
      local--[[float]] lineHeight = 0;
      -- for (ii = startIndex; ii < childCount; ++ii) {
      ii = startIndex
      while ii < childCount do
        child = node.children[ii + 1] --[[ TODO: fix indices ]];
        if getPositionType(child) ~= CSS_POSITION_RELATIVE then
          goto continue_a
        end
        if child.lineIndex ~= i then
          break;
        end
        if not isUndefined(child.layout[dim[crossAxis]]) then
          lineHeight = fmaxf(
            lineHeight,
            child.layout[dim[crossAxis]] + getMarginAxis(child, crossAxis)
          );
        end

        ::continue_a::
        ii = ii + 1
      end
      endIndex = ii;
      lineHeight = lineHeight + crossDimLead;

      -- for (ii = startIndex; ii < endIndex; ++ii) {
      ii = startIndex
      while ii < endIndex do
        child = node.children[ii + 1] --[[ TODO: fix indices ]];
        if getPositionType(child) ~= CSS_POSITION_RELATIVE then
          goto continue_b
        end

        do
          local--[[css_align_t]] alignContentAlignItem = getAlignItem(node, child);
          if alignContentAlignItem == CSS_ALIGN_FLEX_START then
            child.layout[pos[crossAxis]] = currentLead + getLeadingMargin(child, crossAxis);
          elseif alignContentAlignItem == CSS_ALIGN_FLEX_END then
            child.layout[pos[crossAxis]] = currentLead + lineHeight - getTrailingMargin(child, crossAxis) - child.layout[dim[crossAxis]];
          elseif alignContentAlignItem == CSS_ALIGN_CENTER then
            local--[[float]] childHeight = child.layout[dim[crossAxis]];
            child.layout[pos[crossAxis]] = currentLead + (lineHeight - childHeight) / 2;
          elseif alignContentAlignItem == CSS_ALIGN_STRETCH then
            child.layout[pos[crossAxis]] = currentLead + getLeadingMargin(child, crossAxis);
            -- TODO(prenaux): Correctly set the height of items with nil
            --                (auto) crossAxis dimension.
          end
        end

        ::continue_b::
        ii = ii + 1
      end

      currentLead = currentLead + lineHeight;

      i = i + 1
    end
  end

  local--[[bool]] needsMainTrailingPos = false;
  local--[[bool]] needsCrossTrailingPos = false;

  -- If the user didn"t specify a width or height, and it has not been set
  -- by the container, then we set it via the children.
  if not isMainDimDefined then
    node.layout[dim[mainAxis]] = fmaxf(
      -- We"re missing the last padding at this point to get the final
      -- dimension
      boundAxis(node, mainAxis, linesMainDim + getTrailingPaddingAndBorder(node, mainAxis)),
      -- We can never assign a width smaller than the padding and borders
      paddingAndBorderAxisMain
    );

    if mainAxis == CSS_FLEX_DIRECTION_ROW_REVERSE or
        mainAxis == CSS_FLEX_DIRECTION_COLUMN_REVERSE then
      needsMainTrailingPos = true;
    end
  end

  if not isCrossDimDefined then
    node.layout[dim[crossAxis]] = fmaxf(
      -- For the cross dim, we add both sides at the end because the value
      -- is aggregate via a max function. Intermediate negative values
      -- can mess this computation otherwise
      boundAxis(node, crossAxis, linesCrossDim + paddingAndBorderAxisCross),
      paddingAndBorderAxisCross
    );

    if crossAxis == CSS_FLEX_DIRECTION_ROW_REVERSE or
        crossAxis == CSS_FLEX_DIRECTION_COLUMN_REVERSE then
      needsCrossTrailingPos = true;
    end
  end

  -- <Loop F> Set trailing position if necessary
  if needsMainTrailingPos or needsCrossTrailingPos then
    -- for (i = 0; i < childCount; ++i) {
    i = 0
    while i < childCount do
      child = node.children[i + 1] --[[ TODO: fix indices ]];

      if needsMainTrailingPos then
        setTrailingPosition(node, child, mainAxis);
      end

      if needsCrossTrailingPos then
        setTrailingPosition(node, child, crossAxis);
      end

      i = i + 1
    end
  end

  -- <Loop G> Calculate dimensions for absolutely positioned elements
  currentAbsoluteChild = firstAbsoluteChild;
  while currentAbsoluteChild ~= nil do
    -- Pre-fill dimensions when using absolute position and both offsets for
    -- the axis are defined (either both left and right or top and bottom).
    -- for (ii = 0; ii < 2; ii++) {
    ii = 0
    while ii < 2 do
      -- axis = (ii ~= 0) ? CSS_FLEX_DIRECTION_ROW : CSS_FLEX_DIRECTION_COLUMN;
      if ii ~= 0 then
        axis = CSS_FLEX_DIRECTION_ROW
      else
        axis = CSS_FLEX_DIRECTION_COLUMN
      end

      if not isUndefined(node.layout[dim[axis]]) and
          not isDimDefined(currentAbsoluteChild, axis) and
          isPosDefined(currentAbsoluteChild, leading[axis]) and
          isPosDefined(currentAbsoluteChild, trailing[axis]) then
        currentAbsoluteChild.layout[dim[axis]] = fmaxf(
          boundAxis(currentAbsoluteChild, axis, node.layout[dim[axis]] -
            getBorderAxis(node, axis) -
            getMarginAxis(currentAbsoluteChild, axis) -
            getPosition(currentAbsoluteChild, leading[axis]) -
            getPosition(currentAbsoluteChild, trailing[axis])
          ),
          -- You never want to go smaller than padding
          getPaddingAndBorderAxis(currentAbsoluteChild, axis)
        );
      end

      if isPosDefined(currentAbsoluteChild, trailing[axis]) and
          not isPosDefined(currentAbsoluteChild, leading[axis]) then
        currentAbsoluteChild.layout[leading[axis]] =
          node.layout[dim[axis]] -
          currentAbsoluteChild.layout[dim[axis]] -
          getPosition(currentAbsoluteChild, trailing[axis]);
      end

      ii = ii + 1
    end

    child = currentAbsoluteChild;
    currentAbsoluteChild = currentAbsoluteChild.nextAbsoluteChild;
    child.nextAbsoluteChild = nil;
  end
end

function layoutNode(node, parentMaxWidth, parentDirection)
  node.shouldUpdate = true;

  local direction = node.style.direction or CSS_DIRECTION_LTR;
  local skipLayout =
    not node.isDirty and
    node.lastLayout and
    node.lastLayout.requestedHeight == node.layout.height and
    node.lastLayout.requestedWidth == node.layout.width and
    node.lastLayout.parentMaxWidth == parentMaxWidth and
    node.lastLayout.direction == direction;

  if skipLayout then
    node.layout.width = node.lastLayout.width;
    node.layout.height = node.lastLayout.height;
    node.layout.top = node.lastLayout.top;
    node.layout.left = node.lastLayout.left;
  else
    node.isDirty = false

    if not node.lastLayout then
      node.lastLayout = {};
    end

    node.lastLayout.requestedWidth = node.layout.width;
    node.lastLayout.requestedHeight = node.layout.height;
    node.lastLayout.parentMaxWidth = parentMaxWidth;
    node.lastLayout.direction = direction;

    -- Reset child layouts
    for _, child in ipairs(node.children) do
      child.layout.width = nil;
      child.layout.height = nil;
      child.layout.top = 0;
      child.layout.left = 0;
    end

    if parentMaxWidth == nil then parentMaxWidth = 0 / 0 end
    layoutNodeImpl(node, parentMaxWidth, parentDirection);

    node.lastLayout.width = node.layout.width;
    node.lastLayout.height = node.layout.height;
    node.lastLayout.top = node.layout.top;
    node.lastLayout.left = node.layout.left;

    node:__post_reflow()
    return true
  end

  return false
end

return {
  layoutNode = layoutNode,
  fillNodes = fillNodes,
  computeLayout = function(node)
    fillNodes(node)
    return layoutNode(node)
  end
};
