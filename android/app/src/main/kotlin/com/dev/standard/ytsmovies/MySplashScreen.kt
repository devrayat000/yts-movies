package com.dev.standard.ytsmovies

import android.os.Bundle
import android.view.View
import android.view.LayoutInflater
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.view.animation.AnticipateInterpolator
import android.content.Context
import io.flutter.embedding.android.SplashScreen

class MySplashScreen : SplashScreen {
    private var view: View? = null

    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? {
        view = LayoutInflater.from(context).inflate(R.layout.splash_layout, null, false)
        return view
    }

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        val animator = AnimatorSet().apply {
            play(ObjectAnimator.ofFloat(
                view,
                View.TRANSLATION_Y,
                0f,
                -(view?.height?.toFloat() ?: 32f)
            )
            ).apply {
                with(ObjectAnimator.ofFloat(view, View.ALPHA, 1f, 0.8f))
            }
            duration = 500L
            interpolator = AnticipateInterpolator()
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    onTransitionComplete.run()
                }
            })
            start()
        }

    }
}