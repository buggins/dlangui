// Written in the D programming language.

/**
This module contains progress bar controls implementation.

ProgressBarWidget - progeress bar control


Synopsis:

----
import dlangui.widgets.progressbar;

auto pb = new ProgressBarWidget();
// set progress
pb.progress = 300; // 0 .. 1000
// set animation interval
pb.animationInterval = 50; // 50 milliseconds

// for indeterminate state: set progress to PROGRESS_INDETERMINATE (-1)
pb.progress = PROGRESS_INDETERMINATE;

----

Copyright: Vadim Lopatin, 2016
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.progressbar;

import dlangui.widgets.widget;

enum PROGRESS_INDETERMINATE = -1;
enum PROGRESS_HIDDEN = -2;
enum PROGRESS_ANIMATION_OFF = 0;
enum PROGRESS_MAX = 1000;

/// Base for different progress bar controls
class AbstractProgressBar : Widget {
    this(string ID = null, int progress = PROGRESS_INDETERMINATE) {
        super(ID);
        _progress = progress;
    }

    protected int _progress = PROGRESS_INDETERMINATE;

    /// Set current progress value, 0 .. 1000; -1 == indeterminate, -2 == hidden
    @property AbstractProgressBar progress(int progress) {
        if (progress < -2)
            progress = -2;
        if (progress > 1000)
            progress = 1000;
        if (_progress != progress) {
            _progress = progress;
            invalidate();
        }
        requestLayout();
        return this;
    }
    /// Get current progress value, 0 .. 1000; -1 == indeterminate
    @property int progress() {
        return _progress;
    }
    /// returns true if progress bar is in indeterminate state
    @property bool indeterminate() { return _progress == PROGRESS_INDETERMINATE; }

    protected int _animationInterval = 0; // no animation by default
    /// get animation interval in milliseconds, if 0 - no animation
    @property int animationInterval() { return _animationInterval; }
    /// set animation interval in milliseconds, if 0 - no animation
    @property AbstractProgressBar animationInterval(int animationIntervalMillis) {
        if (animationIntervalMillis < 0)
            animationIntervalMillis = 0;
        if (animationIntervalMillis > 5000)
            animationIntervalMillis = 5000;
        if (_animationInterval != animationIntervalMillis) {
            _animationInterval = animationIntervalMillis;
            if (!animationIntervalMillis)
                stopAnimation();
            else
                scheduleAnimation();
        }
        return this;
    }

    protected ulong _animationTimerId;
    protected void scheduleAnimation() {
        if (!visible || !_animationInterval) {
            if (_animationTimerId)
                stopAnimation();
            return;
        }
        stopAnimation();
        _animationTimerId = setTimer(_animationInterval);
        invalidate();
    }

    protected void stopAnimation() {
        if (_animationTimerId) {
            cancelTimer(_animationTimerId);
            _animationTimerId = 0;
        }
        _lastAnimationTs = 0;
    }

    protected int _animationSpeedPixelsPerSecond = 20;
    protected long _animationPhase;
    protected long _lastAnimationTs;
    /// called on animation timer
    protected void onAnimationTimer(long millisElapsed) {
        _animationPhase += millisElapsed;
        invalidate();
    }

    /// handle timer; return true to repeat timer event after next interval, false cancel timer
    override bool onTimer(ulong id) {
        if (id == _animationTimerId) {
            if (!visible || _progress == PROGRESS_HIDDEN) {
                stopAnimation();
                return false;
            }
            long elapsed = 0;
            long ts = currentTimeMillis;
            if (_lastAnimationTs) {
                elapsed = ts - _lastAnimationTs;
                if (elapsed < 0)
                    elapsed = 0;
                else if (elapsed > 5000)
                    elapsed = 5000;
            }
            _lastAnimationTs = ts;
            onAnimationTimer(elapsed);
            return _animationInterval != 0;
        }
        // return true to repeat after the same interval, false to stop timer
        return super.onTimer(id);
    }
}

/// Progress bar widget
class ProgressBarWidget : AbstractProgressBar {
    this(string ID = null, int progress = PROGRESS_INDETERMINATE) {
        super(ID, progress);
        styleId = STYLE_PROGRESS_BAR;
    }

    /**
    Measure widget according to desired width and height constraints. (Step 1 of two phase layout).

    */
    override void measure(int parentWidth, int parentHeight) {
        int h = 0;
        int w = 0;
        DrawableRef gaugeDrawable = style.customDrawable("progress_bar_gauge");
        DrawableRef indeterminateDrawable = style.customDrawable("progress_bar_indeterminate");
        if (!gaugeDrawable.isNull) {
            if (h < gaugeDrawable.height)
                h = gaugeDrawable.height;
        }
        if (!indeterminateDrawable.isNull) {
            if (h < indeterminateDrawable.height)
                h = indeterminateDrawable.height;
        }
        measuredContent(parentWidth, parentHeight, w, h);
    }


    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        DrawableRef animDrawable;
        if (_progress >= 0) {
            DrawableRef gaugeDrawable = style.customDrawable("progress_bar_gauge");
            animDrawable = style.customDrawable("progress_bar_gauge_animation");
            int x = rc.left + _progress * rc.width / PROGRESS_MAX;
            if (!gaugeDrawable.isNull) {
                gaugeDrawable.drawTo(buf, Rect(rc.left, rc.top, x, rc.bottom));
            } else {
            }
        } else {
            DrawableRef indeterminateDrawable = style.customDrawable("progress_bar_indeterminate");
            if (!indeterminateDrawable.isNull) {
                indeterminateDrawable.drawTo(buf, rc);
            }
            animDrawable = style.customDrawable("progress_bar_indeterminate_animation");
        }
        if (!animDrawable.isNull && _animationInterval) {
            if (!_animationTimerId)
                scheduleAnimation();
            int w = animDrawable.width;
            _animationPhase %= w * 1000;
            animDrawable.drawTo(buf, rc, 0, cast(int)(_animationPhase * _animationSpeedPixelsPerSecond / 1000), 0);
            //Log.d("progress animation draw ", _animationPhase, " rc=", rc);
        }
    }
}
