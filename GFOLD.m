% Neal Bhasin
% 2015-04-21
% G-FOLD outer time-optimization routine

% Vehicle/planet parameters p must include:
%  p.phi ; p.T_max ; p.max_throttle ; p.min_throttle ; p.Isp ; p.m_dry ; p.g

% 
function [m_used, r, v, u, m] = GFOLD(N, r0, v0, rf, vf, m_wet, p)
    tic;
    g0 = 9.80665; % Standard earth gravity [m/s^2]
    alpha = 1 / (p.Isp * g0 * cosd(p.phi));
    r1 = p.min_throttle * p.T_max * cosd(p.phi);
    r2 = p.max_throttle * p.T_max * cosd(p.phi);
    tf_min = p.m_dry * norm(vf - v0) / r2;
    tf_max = (m_wet - p.m_dry) / (alpha * r1);
    
    cvx_solver SEDUMI
    obj_fun = @(t)( GFOLD_fix_time(t, N, r0, v0, rf, vf, m_wet, p) );
    options = optimset('TolX',0.5,'Display','iter');
    tf_opt = fminbnd(obj_fun, tf_min, tf_max, options);
    
    % Re-run optimal case
    [m_used, r, v, u, m] = GFOLD_fix_time(tf_opt, N, r0, v0, rf, vf, m_wet, p);
    
    toc;
end