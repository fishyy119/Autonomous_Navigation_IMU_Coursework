function x_est = LS(z,H,sigma,option)
N =size(z,1);
M =size(H,2);
%% 量测建模
 R = diag(sigma.*sigma);
 W = inv(R);
switch option
    case 'ls'
        x_est = inv(H'*H)*H'*z;
    case 'wls'
        x_est_wls = inv(H'*W*H)*H'*W*z;
    case 'rwls'
       
        P = inv(H(1:M,:)'*W(1:M,1:M)*H(1:M,:));
        x_est_rwls = P*H(1:M,:)'*W(1:M,1:M)*z(1:M,:);
        for i= M+1:N
            P = P-P*H(i,:)'*((R(i,i)+H(i,:)*P*H(i,:)')^-1)*H(i,:)*P;
            x_est_rwls= x_est_rwls+P*H(i,:)'*W(i,i)*(z(i,:)-H(i,:)*x_est_rwls);
        end
end
end





